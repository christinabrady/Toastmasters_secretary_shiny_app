# setwd("~/Documents/Toastmasters/secretary_shiny_app")
options(stringsAsFactors = FALSE)
library(shiny)
library(RODBC)
library(ggvis)
library(xtable)

source("./include/db_connection.R")

roster <- sqlQuery(tm, "SELECT name FROM members WHERE status = 'Active'")

active_member_list <- c(" ", roster$name)

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
				"Best Table Topics Response"
				)

speaker_fields <- sprintf("s%i_dat", 1:5)

meetings_to_date <- sqlQuery(tm, "SELECT DISTINCT meeting_date FROM meetings")
meetings_to_date$ui_format <- format(as.Date(meetings_to_date$meeting_date), "%B %d, %Y")



### data prep:

active_members <- as.character(sqlQuery(tm, "SELECT COUNT(*) FROM members WHERE status = 'Active'"))

## monthly attendance:
monthly_attend_prep <- function(){
	allmeet  <- sqlQuery(tm, "SELECT * FROM meetings")
	allmeet$member <- ifelse(allmeet$name != 'guest', "Members", "Guests")
	meet_tots <- as.data.frame(with(allmeet, table(meeting_date)))
	meet_tots$member <- "Total"
	mem_non <- rbind(meet_tots, as.data.frame(with(allmeet, table(meeting_date, member))))
	mem_non <- subset(mem_non, meeting_date != "meeting_date") ## silly mistake pushing to the database
	mem_non$date_long <- as.character(format(as.Date(mem_non$meeting_date), "%B %d, %Y"))
	mem_non$date_long <- factor(mem_non$date_long, levels = unique(mem_non$date_long))
	return(mem_non)
}

monthly_new_mem_data_prep <- function(){
	allmeet  <- sqlQuery(tm, "SELECT * FROM meetings")
	### new members per month
	mem_split <- split(subset(allmeet, select = c("name", "meeting_date")), allmeet$name)
	first_meet <- lapply(mem_split, function(x){
		x <- x[order(x$meeting_date), ]
		return(head(x, 1))
		})
	first_meetdf <- do.call(rbind, first_meet)
	first_meetdf$meeting_dateMY <- format(as.Date(first_meetdf$meeting_date), "%B %Y")
	monthly_new_mem <- as.data.frame(with(first_meetdf, table(meeting_dateMY)), stringsAsFactors = FALSE)


	### take out July and August 2014 because I only have data since July 2014 so all current members at that time have a first meeting date of July or August 2014
	monthly_new_mem <- monthly_new_mem[!(monthly_new_mem$meeting_dateMY %in% c("July 2014", "August 2014")),]
	monthly_new_mem$order_var <- as.Date(paste("01", monthly_new_mem$meeting_dateMY), "%d %B %Y")
	monthly_new_mem$meeting_dateMY <- factor(monthly_new_mem$meeting_dateMY, levels = monthly_new_mem$meeting_dateMY[order(monthly_new_mem$order_var)])

	### add names so that I can plot them:
	MYsplit <- split(first_meetdf, first_meetdf$meeting_dateMY)
	MYmem <- lapply(MYsplit, function(x){
		xn <- paste(x$name, collapse = ", ")
		return(xn)
		})
	MYmemdf <- stack(MYmem)
	colnames(MYmemdf) <- c("names", "meeting_dateMY")

	new_mem <- merge(monthly_new_mem, MYmemdf)
	return(new_mem)

}

