module main

import os
import time

// brand_banner is a minimal terminal hero (ASCII, no emoji).
pub fn brand_banner() string {
	return 'create-vlang-app — scaffold V projects'
}

// spinner_allowed is the pure gating rule: spin only on an interactive TTY
// outside CI. stdout stays machine-readable everywhere else.
pub fn spinner_allowed(ci_set bool, interactive bool, is_tty bool) bool {
	return interactive && !ci_set && is_tty
}

pub fn spinner_enabled(interactive bool) bool {
	ci := os.getenv('CI') != ''
	return spinner_allowed(ci, interactive, os.is_atty(1) > 0)
}

// SpinnerDone is heap-allocated so it outlives the start_spinner frame
// the animation thread reads it from.
struct SpinnerDone {
mut:
	done bool
}

// Spinner animates a progress indicator on stderr while scaffolding runs.
// Start it with start_spinner; it renders nothing when disabled (CI,
// non-TTY, non-interactive), so callers need no conditionals.
pub struct Spinner {
pub mut:
	label  string
	state  &SpinnerDone
	handle thread
}

pub fn start_spinner(label string, interactive bool) ?Spinner {
	if !spinner_enabled(interactive) {
		return none
	}
	state := &SpinnerDone{}
	handle := spawn spin_loop(label, state)
	return Spinner{label, state, handle}
}

pub fn (s Spinner) stop() {
	unsafe {
		s.state.done = true
	}
	s.handle.wait()
	eprint('\r${' '.repeat(s.label.len + 4)}\r')
}

fn spin_loop(label string, state &SpinnerDone) {
	frames := ['|', '/', '-', '\\']
	mut i := 0
	for {
		unsafe {
			if state.done {
				break
			}
		}
		eprint('\r${frames[i]} ${label} ...')
		i = (i + 1) % frames.len
		time.sleep(80 * time.millisecond)
	}
}

pub fn success_msg(project string) string {
	return 'OK  Scaffolded ${project}'
}

pub fn error_msg(err string) string {
	return 'ERR ${err}'
}
