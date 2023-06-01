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

/// Simple bind-view [Router] implementation
class SimpleRouter extends Router {
    /// Initialize a view router from a list of views
    SimpleRouter.from(List<View> views) {
        addViews(views);
    }

    /// Add more views to the router
    void addViews(List<View> views) {
        views.forEach((view) {
            addView(view);
        });
        if (this.path == null) {
            var hash = window.location.hash;
            if (hash != '') {
                this.path = hash;
            } else {
                this.path = views.first.path;
            }
        }
        window.onHashChange.listen((HashChangeEvent e) {
            this.path = window.location.hash;
        });
    }
}