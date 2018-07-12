require 'sqlite3'

 module Selection
   def find(*ids)

    if ids.kind_of? Integer && ids > 0
      if ids.length == 1
        find_one(ids.first)
      else
        rows = connection.execute <<-SQL
          SELECT #{columns.join ","} FROM #{table}
          WHERE id IN (#{ids.join(",")});
        SQL
        rows_to_array(rows)
      end
     else
       puts "The id you entered is invalid"
     end
    end

   def find_one(id)
     if ids.kind_of? Integer && ids > 0
       row = connection.get_first_row <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         WHERE id = #{id};
        SQL

         init_object_from_row(row)

      else
        puts "The id you entered is invalid"
      end
   end

   def find_by(attribute, value)
     rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
      SQL

      if rows_to_array(rows) == []
        puts "Incorrect entry"
      else
        rows_to_array(rows)
      end
   end

   def method_missing(m, *args, &block)
     if COLUMNS != nil
       COLUMNS.find do |columns|
         puts "This is the column: #{column}"
         match = column
         if match  === method
           puts "This method exists"
           find_by(match, args[0])
         end
       end
      else
        super
        puts "There's no method called #{method}"
      end
    end

    def find_each(start: 2000, batch_size: 2000)
      rows = connection.execute <<-SQL
        SELECT#{columns.join ","} FROM #{table}
        LIMIT #{batch_size}
      SQL

      for row in rows_to_array(row)
        yield(row)
      end
    end

    def find_in_batches(start: 4000, batch_size: 2000)
      rows = connection.execute <<-SQL
        SELECT #{COLUMNS.join ","} FROM #{table}
        LIMIT #{batch_size}
      SQL

      yeild(rows_to_array(rows))
    end


   end

   def take(num=1)
     if num > 1
       rows = connection.execute <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         ORDER BY random()
         LIMIT #{num}
       SQL

       rows_to_array(rows)
      else
        take_one
      end
   end

   def take_one
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY random()
       LIMIT 1;
      SQL

      init_object_from_row(row)
   end

   def first
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id ASC LIMIT 1;
     SQL

     init_object_from_row(row)
   end

   def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
   end

   def all
     rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
     SQL

     rows_to_array(rows)
   end

   private
   def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
   end

   def rows_to_array(rows)
     rows.map { |row| new(Hash[columns.zip(row)]) }
   end
 end
