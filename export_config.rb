require "mysql2"

mysql_ip = "192.168.6.135"
mysql_port = "3306"
mysql_username = "root"
mysql_password = "root"
mysql_database = "pkm_config_master"
config_data_path = "./config_data"

client = Mysql2::Client.new(:host => mysql_ip,
							:port => mysql_port,
							:username => mysql_username,
							:password => mysql_password,
							:database => mysql_database
							)

puts "select table_name from information_schema.tables where table_schema = \"#{mysql_database}\""
puts "select column_name, data_type from information_schema.columns where table_schema = \"#{mysql_database}\" and table_name = \"{table_name}\""
puts "select * from #{mysql_database}.{table_name}"

tableNameList = client.query("select table_name from information_schema.tables where table_schema = \"#{mysql_database}\"")
tableNameList.each do |table_name|
	puts "select column_name, data_type from information_schema.columns where table_schema = \"#{mysql_database}\" and table_name = \"#{table_name["table_name"]}\""
	puts "select * from #{mysql_database}.#{table_name["table_name"]}"

	columns = client.query("select column_name, data_type from information_schema.columns where table_schema = \"#{mysql_database}\" and table_name = \"#{table_name["table_name"]}\"")
	results = client.query("select * from #{mysql_database}.#{table_name["table_name"]}")

	first = true
	File.open("#{config_data_path}/#{table_name["table_name"]}.lua", "w+") do |file|
		file.print "local #{table_name["table_name"]} = {\n"
		results.each do |row|
			file.print "\t[", row[columns.first["column_name"]], "] = { "
			columns.each do |column|
				if first == false then
					file.print ", "
				end

				file.print column["column_name"], " = "
				if column["data_type"] == "varchar" or column["data_type"] == "datetime" then
					file.print "\""
				end
				file.print row[column["column_name"]].to_s.gsub(/\"/, "\\\"")
				if column["data_type"] == "varchar" or column["data_type"] == "datetime" then
					file.print "\""
				end
				first = false
			end

			file.print " },\n"
			first = true
		end
		file.print "}\n\n"
		file.print "return #{table_name["table_name"]}"
	end
end


# select column_name from information_schema.columns where table_schema = 'pkm_log_4' and table_name = 'chat_msg';
# select table_name from information_schema.tables where table_schema = 'pkm_log_4' and table_name = 'chat_msg';
# select constraint_type from information_schema.table_constraints where table_schema = 'pkm_log_4' and table_name = 'chat_msg';

# select column_name, constraint_type from information_schema.columns c, information_schema.table_constraints tc where c.table_name = tc.table_name and c.table_schema = 'pkm_log_4' and c.table_name = 'chat_msg';

# select column_name, constraint_type from information_schema.columns as c inner join information_schema.table_constraints tc on c.table_name = tc.table_name
# 	where c.table_schema = 'pkm_log_4' and c.table_name = 'chat_msg' where constraint_type = 'PRIMARY KEY';
# SELECT
#   t.TABLE_NAME,
#   t.CONSTRAINT_TYPE,
#   c.COLUMN_NAME,
#   c.ORDINAL_POSITION
# FROM
#   INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS t,
#   INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS c,
#   information_schema.TABLES AS ts
# WHERE
#   t.TABLE_NAME = c.TABLE_NAME
#   -- AND t.TABLE_SCHEMA = 数据库名称
