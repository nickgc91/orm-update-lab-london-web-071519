require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade 
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id 
      self.update
    else
      sql = <<-SQL
      INSERT INTO students(name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
    end

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(array)
    new_student = Student.new(array[0], array[1], array[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * 
    FROM students
    WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).first

    self.new_from_db(row)
  end

end
