library(shiny)
# library(RODBC)

setwd("~/Documents/Toastmasters/secretary_shiny_app")

roster <- read.csv("../Roster/MembershipRosterAug17.csv") ## change this to a database call: all members WHERE status = 'Active'

active_member_list <- c("Not Applicable", roster$Name, "guest")

field_names <- c("Toastmaster", 
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

roles_list <- gsub("_", " ", field_names)

awards_list <- c("Best Speaker", 
				"Best Evaluator", 
				"Best Table Topics Response",
				"Other")

meetings_to_date <- '2015-08-19' ## change to a pull from the data base on date and format to Aug 17 2015

# input_list <- paste("input$", roles_list, sep = "")

### data capture:
# attend <- vector("list", length(roles_list))
# names(attend) <- roles_list


