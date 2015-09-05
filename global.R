library(shiny)
library(RODBC)

source("./include/db_connection.R")

setwd("~/Documents/Toastmasters/secretary_shiny_app")

roster <- sqlQuery(tm, "SELECT name FROM members WHERE status = 'Active'")

active_member_list <- roster$name

roles_list <- c("Toastmaster", 
				"Thought_of_the_Day", 
				"Ah_Counter",
				"Grammarian", 
				"Timer/Vote_Counter",
				"General_Evaluator", 
				"Speaker1", 
				"Speaker2", 
				"Speaker3", 
				"Speaker4", 
				"Speaker5",
				"Evaluator1",
				"Evaluator2",
				"Evaluator3",
				"Evaluator4",
				"Evaluator5",
				"Table_Topics_Master", 
				"Attendee1", 
				"Attendee2", 
				"Attendee3", 
				"Attendee4", 
				"Attendee5")

field_names <- gsub("_", " ", roles_list)

awards_list <- c("Best Speaker", 
				"Best Evaluator", 
				"Best Table Topics Response",
				"Other")

meetings_to_date <- '2015-08-19' ## change to a pull from the data base on date and format to Aug 17 2015



