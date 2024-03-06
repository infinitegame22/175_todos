require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end

  # wrapper for calling exec_params on the instance variable
  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    tuple = result.first # Result object behaves like an array

    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id) # an array of hashes for the todos data of that list
    {id: list_id, name: tuple["name"], todos: todos }
  end

  def all_lists
    sql = "SELECT * FROM lists"
    result = query(sql)

    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)

      {id: list_id, name: tuple["name"], todos: todos}
    end
  end

  def create_new_list(list_name)
    sql = "INSERT INTO lists (name) VALUES ($1)"
    query(sql, name)
  end

  def delete_list(id)
    query("DELETE FROM todos WHERE list_id = $1", id)
	  query("DELETE FROM lists WHERE id = $1", id)
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, id)
  end

  def create_new_todo(list_id, todo_name)
    sql = "INSERT INTO todos (list_id, name) VALUES ($1, $2)"
    query(sql, list_id, todo_name)
  end

  def delete_todo_from_list(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, list_id, todo_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE lists SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_todos_as_completed(list_id)
    sql = "UPDATE TABLE todos SET completed = true WHERE id = $1"
    query(sql, list_id)
  end

  private

  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    todos_result = query(todo_sql, list_id) # PG result object

    todos_result.map do |todo_tuple|
      {id: todo_tuple["id"].to_i, 
        name: todo_tuple["name"],
        completed: todo_tuple["completed"] == "t"}
    end
  end

end

#<PG::Result:0x0000000110f856e0 status=PGRES_TUPLES_OK ntuples=1 nfields=2 cmd_tuples=1>