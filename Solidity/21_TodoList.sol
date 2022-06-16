// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    constructor ( ) {
    }

    function create(string calldata _text) external {
        todos.push(Todo(_text, false));
    }

    function updateText(uint _index, string calldata _text) external {
        todos[_index].text = _text;

        // OR

        // Todo storage todo = todos[_index];
        // todo.text = _text;
    }

    function get(uint _index) external view returns (string memory, bool){
        Todo storage todo = todos[_index];
        // Todo memory todo = todos[_index]; // does a copy

        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}