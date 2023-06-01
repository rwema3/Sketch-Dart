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

/// View interface for [Template] bind-router
abstract class View {
     // View URI
     String path;

     /// Contains the file name and path to the view HTML source
     String source;

     /// Contains the template bindings for the view
     Map bindings;

     /// Default constructor
     View(this.path, this.source, this.bindings);
}