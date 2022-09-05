// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract ToDoList {
    struct Todo { 
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo(_text, false));
    }

    function updateTodo(uint _index, string calldata _text) external {
        todos[_index].text = _text;

        // Todo storage todo = todos[_index];
        // todo.text = _text;
    }
    
    function getTodos() view external returns (Todo[] memory) {
        return todos;
    }
 
    function get(uint _index) view external returns (string memory, bool) {
        // Todo memory todo = todos[_index]; // more gas
        Todo storage todo = todos[_index]; // less gas

        return (todo.text, todo.completed);
    }

    function markComplete(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}