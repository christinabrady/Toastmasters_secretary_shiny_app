### update members

update_members <- function(names, newStatus = "Inactive"){
	source("./include/db_connection.R")
	update_mem_qry <- sprintf("UPDATE members
								SET status = '%s' 
								WHERE name IN (%s)",
								newStatus, paste(sprintf("'%s'", names), collapse = ","))
	sqlQuery(tm, update_mem_qry)
}