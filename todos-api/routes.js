'use strict';
const TodoController = require('./todoController');
module.exports = function (app, {tracer, redisClient, logChannel}) {
  const todoController = new TodoController({tracer, redisClient, logChannel});
  app.route('/api/todos')
    .get(function(req,resp) {return todoController.list(req,resp)})
    .post(function(req,resp) {return todoController.create(req,resp)});

  app.route('/api/todos/:taskId')
    .delete(function(req,resp) {return todoController.delete(req,resp)});
};