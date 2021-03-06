shinyServer(function(input, output, session){

	observe({
		if(input$submitusr == 0){
			return()
		}else{
			output$approved <- reactive({ FALSE })

			if(input$username == username & input$pswd == password){

				output$approved <- reactive({TRUE})
				outputOptions(output, 'approved', suspendWhenHidden = FALSE)
			}
		}
	})
	
	##### update selectize options:
	updateSelectizeInput(session, roles_list[1], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[2], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[3], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[4], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[5], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[6], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[7], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[8], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[9], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[10], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[11], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, roles_list[12], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, awards_field_list[1], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, awards_field_list[2], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, awards_field_list[3], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, "guests", server = T, choices = active_member_list, selected = NULL)


	##### visualizations
	monthly_data <- monthly_attend_prep()
	monthly_data %>% 
		ggvis(x = ~date_long, y= ~Freq, stroke = ~factor(member)) %>%
		layer_lines() %>% 
		layer_points(size = 1, fill = ~factor(member)) %>%
		add_axis("x", properties = axis_props(labels=list(angle=45, align = "left")), title = "", 
			title_offset = 50) %>%
		add_axis("y", title = "Number of people in attendance") %>%
		add_legend(c("fill", "stroke"), title = "") %>%
		add_tooltip(function(data){paste0(data$date_long, "<br>", data$`factor(member)`, ": ", data$Freq)}, "hover") %>%
		add_axis("x", orient = "top", ticks = 0, title = "Meeting Attendance",
	           properties = axis_props(
	             axis = list(stroke = "white"),
	             labels = list(fontSize = 0))) %>%
		bind_shiny("monthly_attend_vis", "monthly_attend_vis_ui")

	new_mem <- monthly_new_mem_data_prep()
	new_mem %>%
			ggvis(x = ~meeting_dateMY, y = ~Freq, fill := "blue", key := ~names) %>%
			layer_bars(fill.hover = "red") %>%
			add_axis("x", properties = axis_props(labels=list(angle=45, align = "left")), title = "", 
				title_offset = 50) %>%
			add_axis("y", title = "Number of new members", ticks = 5) %>%
			add_axis("x", orient = "top", ticks = 0, title = "Number of New Members per Month",
		           properties = axis_props(
		             axis = list(stroke = "white"),
		             labels = list(fontSize = 0))) %>%
			add_tooltip(function(data) data$names) %>%
			hide_legend("fill") %>%
			bind_shiny("new_mem_vis", "new_mem_vis_ui")

	
	### create a flag for formsubmit button
	output$formSubmitted <- reactive({ FALSE })

	outputOptions(output, 'formSubmitted', suspendWhenHidden = FALSE)

		observe({
		if(input$submitbtn == 0){
			return()
		} else {
			### read info into a data frame
			isolate({
				### collect attendence info
				memb <- unlist(lapply(roles_list[1:7], function(x) x <- input[[x]]))

				rolesdf <- data.frame(meeting_date = rep(input$meeting_date, 7),
									role = roles_list[1:7], 
									name = memb, 
									stringsAsFactors = FALSE)
				

				speakers <- input[[roles_list[8]]]

				speakersdf <- data.frame(meeting_date = rep(input$meeting_date, length(speakers)), 
									role = rep("speaker", length(speakers)), 
									name = speakers,
									stringsAsFactors = FALSE
									)
				
				eval <- input[[roles_list[9]]]
				evaldf <- data.frame(meeting_date = rep(input$meeting_date, length(eval)), 
									role = rep("evaluator", length(eval)), 
									name = eval, stringsAsFactors = FALSE
									)
				
				attend <- input[[roles_list[10]]]
				attenddf <- data.frame(meeting_date = rep(input$meeting_date, length(attend)), 
									role = rep("attendee", length(attend)), 
									name = attend, stringsAsFactors = FALSE
									)
				

				contestchairdf <- data.frame(meeting_date = input$meeting_date, 
									role = "contest_chair", 
									name = input[[roles_list[11]]], stringsAsFactors = FALSE
									)
				

				judges <- input[[roles_list[12]]]
				judgesdf <- data.frame(meeting_date = rep(input$meeting_date, length(judges)), 
									role = rep("contest_judge", length(judges)), 
									name = judges, stringsAsFactors = FALSE
									)
				

				### collect guest names: 
				guests <- input$guests
				guestsdf <- data.frame(meeting_date = rep(input$meeting_date, length(guests)), 
										role = rep("guest", length(guests)), 
										name = guests, stringsAsFactors = FALSE
										)	


				meetingdf <- rbind(rolesdf, speakersdf, attenddf, contestchairdf, judgesdf, guestsdf)

				## save attendence info
				
				sqlSave(tm, subset(meetingdf, name != "" & role != "guest"), 'meetings', append = TRUE, varTypes = c(meeting_date = "date", role = "varchar", name = "varchar"), colnames = FALSE, rownames = FALSE)
	

				not_in_db <- meetingdf$name[!(meetingdf$name %in% memdb$name)]
	
				if(length(not_in_db) > 0){
					add_mem <- data.frame(name = not_in_db, member_since = rep(input$meeting_date, length(not_in_db)), status = rep("guest", length(not_in_db)), stringsAsFactors = FALSE)
					add_mem$member_since <- as.Date(add_mem$member_since)
					sqlSave(tm, add_mem, "members", append = TRUE, varTypes = c(name = "varchar", member_since = "date", status = "varchar"), colnames = FALSE, rowname = FALSE)
				}

				## collect speech info
				
				if(input$speechesin == ""){
					speeches <-  " "
				}else{
					speeches <- unlist(strsplit(input$speechesin, ","))	
				}
				if(is.null(speakers)){
					speakers <- " "
				}
					speechesdf <- data.frame(name = speakers, 
										speech_number = speeches, 
										meeting_date = rep(input$meeting_date, length(speeches)), stringsAsFactors = FALSE
										)
				
				
				speechesdf$meeting_date <- as.Date(speechesdf$meeting_date)
				sqlSave(tm, speechesdf, "speeches", append = TRUE, varTypes = c(name = "varchar", meeting_date = "date", speech_number = "varchar"), colnames = FALSE, rowname = FALSE)
			

				## collect award info:`
				bs <- input[[awards_list[1]]]
				be <- input[[awards_list[2]]]
				btt <- input[[awards_list[3]]]

				winnerlist <- replace_null(list(bs, be, btt))
				
				award_date_rep <- length(winnerlist[[1]]) + length(winnerlist[[2]]) + length(winnerlist[[3]])
				
				awardsdf <- data.frame(award = c(rep(awards_list[1], length(winnerlist[[1]])), rep(awards_list[2], length(winnerlist[[2]])), rep(awards_list[3], length(winnerlist[[3]]))),
										name = unlist(winnerlist),
										meeting_date = rep(input$meeting_date, award_date_rep)
					)

				awardsdf$meeting_date <- as.Date(awardsdf$meeting_date)
				sqlSave(tm, subset(awardsdf, name != ""), 'awards', append = TRUE, rownames = FALSE, varTypes = c(award = "varchar", name = "varchar", meeting_date = "date"))


				output$sec_report_fix <- renderUI({
					str1 <- paste(sprintf("Meeting date: %s", format(input$meeting_date), "%B %d, %Y"), collapse = "")
					str2 <- "Attendance"
					str3 <- paste(sprintf("- Members: %s", paste(memb, collapse = ", ")), collapse = "")
					str4 <- paste(sprintf("- Guests: %s", paste(guestsdf$name[guestsdf$name != ""], collapse = ", ")), collapse = "")
					str5 <- "Roles:"
					rls <- field_names[rolesdf$role]  ### fix this
					str6 <- paste(paste(rls[!is.na(rls)], rolesdf$name, sep = ": "), collapse = "<br/>")
					str7 <- "Congratulations to: "
					str8 <- paste(paste(awards_field_list[awardsdf$award], awardsdf$name, sep = ": "), collapse = "<br/>")
					HTML(paste(str1, str2, str3, str4, str5, str6, str7, str8, sep = "<br/>"))
								
				})

				output$formSubmitted <- reactive({ TRUE })

				### thank you message that will show after the form is submitted:
				output$TYmessage <- "Your form has been submitted. Thank you!"

	
			})
		}	
	})


	observe({


			report_qry <- sprintf("SELECT * FROM meetings WHERE meeting_date = '%s'", as.Date(input$report_for, "%B %d, %Y"))
			report_dat <- sqlQuery(tm, report_qry)
			awards_qry <- sprintf("SELECT award, name FROM awards WHERE meeting_date = '%s'", as.Date(input$report_for, "%B %d, %Y"))
			awards_rep <- sqlQuery(tm, awards_qry)
			guest_qry <- sprintf("SELECT name FROM members WHERE status = 'guest' AND member_since = '%s'", as.Date(input$report_for, "%B %d, %Y"))
			guest_dat <- sqlQuery(tm, guest_qry)
			
			output$sec_report <- renderUI({
				str1 <- paste(sprintf("Meeting date: %s", format(unique(report_dat$meeting_date), "%B %d, %Y")), collapse = "")
				str2 <- "Attendance"
				str3 <- paste(sprintf("- Members: %s", paste(report_dat$name[report_dat$name %in% active_member_list], collapse = ", ")), collapse = "")
				str4 <- paste(sprintf("- Guests: %s", paste(guest_dat$name, collapse = ", ")), collapse = "")
				str5 <- "Roles:"
				roles_dat <- subset(report_dat, role != "attendee")
				rls <- field_names[roles_dat$role]  ### fix this
				str6 <- paste(paste(rls[!is.na(rls)], roles_dat$name, sep = ": "), collapse = "<br/>")
				str7 <- paste("Congratulations to: ", collapse = "")
				str8 <- paste(paste(awards_field_list[awards_rep$award], awards_rep$name, sep = ": "), collapse = "<br/>")
				HTML(paste(str1, str2, str3, str4, str5, str6, str7, str8, sep = "<br/>"))

				})
	})

	output$tmg <- renderPlot({
		roleplots(rolesdf, "toastmaster")
		})

	output$todg <- renderPlot({
		roleplots(rolesdf, "though_of_the_day")
		})

	output$thg <- renderPlot({
		roleplots(rolesdf, "ah_counter")
		})

	output$gramg <- renderPlot({
		roleplots(rolesdf, "grammarian")
		})

	output$tvcg <- renderPlot({
		roleplots(rolesdf, "timer_and_vote_counter")
		})

	output$geneg <- renderPlot({
		roleplots(rolesdf, "general_evaluator")
		})

	output$ttg <- renderPlot({
		roleplots(rolesdf, "table_topics")
		})

	output$eeg <- renderPlot({
		roleplots(rolesdf, "evaluator")
		})

	output$ccg <- renderPlot({
		roleplots(rolesdf, "contest_chair")
		})
	output$cjg <- renderPlot({
		roleplots(rolesdf, "chief_judge")
		})
})
