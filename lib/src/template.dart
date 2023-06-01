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

/// Event callback with [router] and [bindings]
typedef EventWithDataCallback(Event event, Router router, Map bindings);

/// This class provides an easy to use templating system with data bindings
///
/// Binding parameters are set throgh dataset attributes.
///
/// Source bindings are set using [Map]s.
class Template {
    static NodeValidatorBuilder _validator;

    /// Bind each parameter
    void _bindParameters(String parameters, Map bindings, BindingCallback callback, { expectFunction: false }) {
        var pattern = new RegExp(r"^{");
        if (!pattern.hasMatch(parameters)) {
            if (bindings.containsKey(parameters)) {
                if (bindings is! ObservableMap) {
                    bindings = new ObservableMap.from(bindings);
                }
                callback(null, parameters, bindings[parameters]);
                bindings.changes.listen((List<ChangeRecord> records) {
                    records.forEach((record) {
                        if (record is MapChangeRecord && record.key == parameters) {
                            callback(null, parameters, bindings[parameters]);
                        }
                    });
                });
            } else {
                print("Warning! Bind target '${parameters}' not found");
            }
        } else {
            var left_key, right_key, value;
            pattern = new RegExp(r"(([\w-]*)\s*:\s*([\w-]*)),?\s*");
            var matches = pattern.allMatches(parameters);
            matches.forEach((match) {
                left_key = match[2];
                right_key = match[3];
                if (expectFunction) {
                    if (bindings[match[3]] is Function) {
                        value = bindings[match[3]];
                    } else {
                        throw new Exception('A function was expected');
                    }
                } else {
                    if (bindings[match[3]] is Function) {
                        value = bindings[match[3]]();
                    } else {
                        value = bindings[match[3]];
                    }
                }
                if (bindings is! ObservableMap) {
                    bindings = new ObservableMap.from(bindings);
                }
                callback(left_key, right_key, value);
                bindings.changes.listen((List<ChangeRecord> records) {
                    records.forEach((record) {
                        if (record is MapChangeRecord && record.key == right_key) {
                            callback(left_key, right_key, record.newValue);
                        }
                    });
                });
            });
        }
    }

    /// Request an set the view router path
    void _requestView(Element element, Router router) {
        var view = router.view;
        HttpRequest.getString(view.source)
            ..then((String fileContents) {
                element.children.clear();
                element.children.add(new Element.html(fileContents, validator: _validator));
                // Resolve all bindings inside the view
                new Template.bindContainer(element, router.bindings, router);
            })
            ..catchError((error) {
                print(error.toString());
            });
    }

    /// Resolve all bindings inside a container element
    Template.bindContainer(Element container, Map bindings, [ Router router ]) {
        // Allow additional elements when adding new content to the DOM
        if (_validator == null) {
            _validator = new NodeValidatorBuilder.common()
                ..allowElement('a', attributes: ['href'])
                ..allowElement('span', attributes: ['data-bind-text', 'data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event'])
                ..allowElement('p', attributes: ['data-bind-text', 'data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event'])
                ..allowElement('button', attributes: ['data-bind-text', 'data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event'])
                ..allowElement('input', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event'])
                ..allowElement('textarea', attributes: ['data-bind-text', 'data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event'])
                ..allowElement('select', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach'])
                ..allowElement('option', attributes: ['data-bind-text', 'data-bind-attr'])
                ..allowElement('ul', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach'])
                ..allowElement('table', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach'])
                ..allowElement('thead', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach'])
                ..allowElement('tbody', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach'])
                ..allowElement('tr', attributes: ['data-bind-attr', 'data-bind-style', 'data-bind-class', 'data-bind-visible', 'data-bind-event', 'data-bind-foreach']);
        }
        // Check that the container is not null
        if (container != null) {
            // Bind each element to the embedded HTML
            container.querySelectorAll('[data-bind-foreach]').forEach((Element element) {
                if (bindings.containsKey(element.dataset['bind-foreach'])) {
                    // bindContainer does not bind attributes in the container
                    var template = new Element.html('<div></div>')
                        ..children.add(element.children.first.clone(true));
                    element.children.clear();
                    List list = bindings[element.dataset['bind-foreach']];
                    if (list is! ObservableList) {
                        list = new ObservableList.from(list);
                    }
                    list.forEach((e) {
                        var new_element = template.clone(true);
                        new Template.bindContainer(new_element, e, router);
                        element.children.add(new_element.children.first);
                    });
                    list.changes.listen((List<ChangeRecord> records) {
                        list.forEach((e) {
                            var new_element = template.clone(true);
                            new Template.bindContainer(new_element, e, router);
                            element.children.add(new_element.children.first);
                        });
                    });
                } else {
                    element.children.clear();
                    print("Warning! Bind target '${element.dataset['bind-foreach']}' not found");
                }
                element.dataset.remove('bind-foreach');
            });
            // Bind variables to element text values
            container.querySelectorAll('[data-bind-text]').forEach((Element element) {
                _bindParameters(element.dataset['bind-text'], bindings, (left_key, right_key, value) {
                    if (left_key == null) {
                        // Textarea onInput bind
                        if (element is TextAreaElement) {
                            element.value = (value is String) ? value : value.toString();
                            element.onKeyUp.listen((event) {
                                bindings[right_key] = element.value;
                            });
                        } else {
                            element.text = (value is String) ? value : value.toString();
                        }
                    }
                });
                element.dataset.remove('bind-text');
            });
            // Bind variables to element innerHtml values
            container.querySelectorAll('[data-bind-html]').forEach((Element element) {
                _bindParameters(element.dataset['bind-html'], bindings, (left_key, right_key, value) {
                    if (left_key == null) {
                        element.setInnerHtml(value);
                    }
                });
                element.dataset.remove('bind-html');
            });
            // Bind variables to element style attribute values
            container.querySelectorAll('[data-bind-style]').forEach((Element element) {
                _bindParameters(element.dataset['bind-style'], bindings, (left_key, rigth_key, value) {
                    if (left_key == null) {
                        element.setAttribute('style', value);
                    } else {
                        element.style.setProperty(left_key, value);
                    }
                });
                element.dataset.remove('bind-style');
            });
            // Bind variables to element attributes
            container.querySelectorAll('[data-bind-attr]').forEach((Element element) {
                _bindParameters(element.dataset['bind-attr'], bindings, (left_key, right_key, value) {
                    if (left_key != null) {
                        // InputElement onInput bind
                        if (left_key == 'value' && element is InputElement) {
                            element.value = (value is String) ? value : value.toString();
                            element.onKeyUp.listen((KeyboardEvent event) {
                                bindings[right_key] = element.value;
                            });
                        } else {
                            element.attributes[left_key] = (value is String) ? value : value.toString();
                        }
                    }
                });
                element.dataset.remove('bind-attr');
            });
            // Bind variables to element class attribute values
            container.querySelectorAll('[data-bind-class]').forEach((Element element) {
                _bindParameters(element.dataset['bind-class'], bindings, (left_key, right_key, value) {
                    if (left_key != null && value) {
                        element.classes.add(left_key);
                    }
                });
                element.dataset.remove('bind-class');
            });
            // Bind variables to element visibility
            container.querySelectorAll('[data-bind-visible]').forEach((Element element) {
                _bindParameters(element.dataset['bind-visible'], bindings, (left_key, right_key, value) {
                    if (left_key == null) {
                        element.hidden = !value;
                    }
                });
                element.dataset.remove('bind-visible');
            });
            // Bind functions to element event handlers
            container.querySelectorAll('[data-bind-event]').forEach((Element element) {
                _bindParameters(element.dataset['bind-event'], bindings, (left_key, right_key, value) {
                    if (left_key != null) {
                        element.on[left_key].listen((event) {
                            if (value is EventCallback) {
                                value(event, router);
                            } else if (value is EventWithDataCallback) {
                                value(event, router, bindings);
                            } else {
                                value(event);
                            }
                        });
                    }
                }, expectFunction: true);
                element.dataset.remove('bind-event');
            });
            // Bind router instances to elements that will act as view containers
            container.querySelectorAll('[data-bind-router]').forEach((Element element) {
                _bindParameters(element.dataset['bind-router'], bindings, (left_key, right_key, router) {
                    if (left_key == null) {
                        if (router is! Router) {
                            throw new Exception("A router was expected");
                        }
                        _requestView(element, router);
                        router.changes.listen((List<ChangeRecord> records) {
                            _requestView(element, router);
                        });
                    }
                });
                element.dataset.remove('bind-router');
            });
            // Show the container
            if (container is TableRowElement) {
            } else {
                container.style.display = 'block';
            }
        }
    }

    /// Resolve all bindings inside a container element identified by a CSS selector
    Template.bind(String selector, Map bindings) : this.bindContainer(querySelector(selector), bindings);
}