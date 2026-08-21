// Copyright 2026 hsy-bit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Logic 4-State logic value: Low, High, High-Z, Unknown.
pub(all) enum LogicState {
  Logic0
  Logic1
  LogicZ
  LogicX
} derive(Eq, Debug)

///|
/// Discrete Digital Event scheduled at target simulation time.
pub struct DigitalEvent {
  time : Double
  delta_cycle : Int
  net_name : String
  new_state : LogicState
} derive(Eq, Debug)

///|
/// Mixed-Signal Event Queue and Digital Signal Registry.
pub struct MixedSignalEngine {
  mut current_time : Double
  events : Array[DigitalEvent]
  signal_states : Map[String, LogicState]
  analog_threshold_low : Double // e.g. 0.8V
  analog_threshold_high : Double // e.g. 2.0V
} derive(Eq, Debug)

///|
/// Creates a new MixedSignalEngine.
pub fn MixedSignalEngine::new(
  v_low : Double,
  v_high : Double,
) -> MixedSignalEngine {
  {
    current_time: 0.0,
    events: [],
    signal_states: Map([]),
    analog_threshold_low: v_low,
    analog_threshold_high: v_high,
  }
}

///|
/// Schedules a digital event in the priority event queue.
pub fn MixedSignalEngine::schedule_event(
  self : MixedSignalEngine,
  time : Double,
  net_name : String,
  new_state : LogicState,
) -> Unit {
  let event : DigitalEvent = { time, delta_cycle: 0, net_name, new_state }
  // Insert in chronological order
  let mut inserted = false
  for i = 0; i < self.events.length(); i = i + 1 {
    if self.events[i].time > time {
      self.events.insert(i, event)
      inserted = true
      break
    }
  }
  if !inserted {
    self.events.push(event)
  }
}

///|
/// Converts analog continuous voltage to 4-state digital logic level.
pub fn MixedSignalEngine::analog_to_digital(
  self : MixedSignalEngine,
  voltage : Double,
) -> LogicState {
  if voltage <= self.analog_threshold_low {
    Logic0
  } else if voltage >= self.analog_threshold_high {
    Logic1
  } else {
    LogicX
  }
}

///|
/// Converts 4-state digital logic level to equivalent analog voltage (0V or Vdd).
pub fn MixedSignalEngine::digital_to_analog(
  _self : MixedSignalEngine,
  state : LogicState,
  vdd : Double,
) -> Double {
  match state {
    Logic0 => 0.0
    Logic1 => vdd
    LogicZ => vdd / 2.0
    LogicX => vdd / 2.0
  }
}

///|
/// Processes all pending events up to time target_time.
pub fn MixedSignalEngine::process_until(
  self : MixedSignalEngine,
  target_time : Double,
) -> Array[DigitalEvent] {
  let processed : Array[DigitalEvent] = []
  while self.events.length() > 0 && self.events[0].time <= target_time {
    let ev = self.events.remove(0)
    self.signal_states[ev.net_name] = ev.new_state
    processed.push(ev)
  }
  self.current_time = target_time
  processed
}
