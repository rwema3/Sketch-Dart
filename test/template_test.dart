import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    useHtmlConfiguration();
    test('data-bind-text', () {
        var data = new ObservableMap.from({ 'text': 'Text' });
        var bind = new Template.bind('#test1', data);
        expect(querySelector('#test1 > p').innerHtml, equals('<span>Text</span>'));
        data['text'] = 'Text2';
        data.changes.listen((record) {
            expect(querySelector('#test1 > p').innerHtml, equals('<span>Text2</span>'));
        });
    });
    new Template.bind('#test2', {
        'style': 'color: red; background-color: black;'
    });
    test('data-bind-style with string', () {
        expect(querySelector('#test2 > p').innerHtml, equals('<span style="color: red; background-color: black;"></span>'));
    });
    new Template.bind('#test3', {
        'textColor': 'red',
        'backgroundColor': () => 'black'
    });
    test('data-bind-style with property map', () {
        expect(querySelector('#test3 > p').innerHtml, equals('<span style="color: red; background-color: black;"></span>'));
    });
    new Template.bind('#test4', {
        'action': '/list'
    });
    test('data-bind-attr', () {
        expect(querySelector('#test4 > p').innerHtml, equals('<a href="/list">Action</a>'));
    });
    new Template.bind('#test5', {
        'isBox': true,
        'isHouse': () => false,
        'isTree': false
    });
    test('data-bind-class', () {
        expect(querySelector('#test5 > p').innerHtml, equals('<span class="box">Action</span>'));
    });
    new Template.bind('#test6', {
        'isMale': true
    });
    test('data-bind-visible', () {
        expect(querySelector('#test6 > p > span').hidden, false);
    });
    new Template.bind('#test7', {
        'click': (event) {
            querySelector('#test7 a').setInnerHtml('Clicked');
        }
    });
    test('data-bind-event', () {
        querySelector('#test7 a').click();
        expect(querySelector('#test7 a').innerHtml, equals('Clicked'));
    });
    var view_1 = new SimpleView('#/template_test', 'template_test_view.html', { 'test': 'Test' });
    var view_2 = new SimpleView(r'#/template_test/(\d+)', 'template_test_view.html', (parameters) => { 'test': 'Test ' + parameters[0] });
    var router = new SimpleRouter([view_1, view_2]);
    var data = { 'router': router };
    var bind = new Template.bind('#test8', data);
    test('data-bind-router', () {
        expect(view_1.future, completion(equals('<p>Test</p>')));
    });
    test('data-bind-router with path change', () {
        router.path = '#/template_test/1';
        expect(view_2.future, completion(equals('<p>Test 1</p>')));
    });
    new Template.bind('#test10', {
        'list': [ { 'url': '/view_1', 'label': 'View 1' }, { 'url': '/view_2', 'label': 'View 2' }]
    });
    test('data-bind-foreach', () {
        expect(querySelector('#test10 ul').innerHtml, equals('<li style="display: block;"><a href="/view_1">View 1</a></li><li style="display: block;"><a href="/view_2">View 2</a></li>'));
    });
}