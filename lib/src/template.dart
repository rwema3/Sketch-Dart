// Copyright 2014 Marcos Cooper <marcos@releasepad.com>
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

part of sketch;

/// Binding callback definition
///
/// Where [left_key] refers to the parameter key, [right_key] refers to the
/// key inside the data source and [value] refers to the value inside
/// the data source for the [right_key].
typedef BindingCallback(String left_key, String right_key, value);

/// Event callback with [router]
typedef EventCallback(Event event, Router router);

/