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

/// Router interface for [Template] bind-router
abstract class Router extends Object with ChangeNotifier {
    // Current path
    var _path;

    /// True if this router should pushState
    bool pushState;

    // Views
    List<View> _views;

    /// Getter for the current path
    @reflectable get path => _path;

    /// Setter for the current path
    @reflectable set path(value) {
        _path = notifyPropertyChange(#path, _path, value);
        if (pushState == null || pushState) {
            window.history.pushState(null, '', value);
        }
    }

    /// Add a new view  to the router
    void addView(View view) {
        if (_views == null) {
            _views = new List();
        }
        _views.add(view);
    }

    /// Get the current view
    ///
    /// The current view is resolved by checking all view paths and returning the view associated to the current path
    View get view {
        for (View view in _views) {
            var pattern = new RegExp("^" + view.path.replaceAll('/', r'\/') + "\$");
            if (pattern.hasMatch(_path)) {
