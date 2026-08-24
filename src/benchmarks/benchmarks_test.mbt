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
test "Benchmark harness uses executable package smoke checks" {
  let registry = BenchmarkHarness::default()
  assert_eq(registry.total_suites, 31)
  assert_eq(registry.total_tests, 310)
  assert_true(BenchmarkHarness::smoke_check())
}
