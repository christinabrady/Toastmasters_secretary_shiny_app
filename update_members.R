### update members

update_members <- function(names, newStatus = "Inactive"){
	source("./include/db_connection.R")
	member_since_qry <- sprintf("SELECT member_since 
								FROM members 
								WHERE name IN (%s)", 
								paste(sprintf("'%s'", names), collapse = ","))
	member_since <- sqlQuery(tm, member_since_qry)
	print(length(names))
	print(length(member_since))
	df <- data.frame(name = names, member_since = member_since$member_since, status = rep(newStatus, length(names)))

	sqlUpdate(tm, df, tablename = "members", index = "status")
}