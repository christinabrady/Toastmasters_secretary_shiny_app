shinyServer(function(input, output, session){
	
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
	updateSelectizeInput(session, awards_list[1], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, awards_list[2], server = T, choices = active_member_list, selected = NULL)
	updateSelectizeInput(session, awards_list[3], server = T, choices = active_member_list, selected = NULL)


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

	
	### thank you message that will show after the form is submitted:
	output$TYmessage <- renderText({
		"Thank you. Please see Attendence Report for the meeting minutes."
		})

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
									name = memb)
				

				speakers <- input[[roles_list[8]]]

				speakersdf <- data.frame(meeting_date = rep(input$meeting_date, length(speakers)), 
									role = rep("speaker", length(speakers)), 
									name = speakers
									)
				
				eval <- input[[roles_list[9]]]
				evaldf <- data.frame(meeting_date = rep(input$meeting_date, length(eval)), 
									role = rep("evaluator", length(eval)), 
									name = eval
									)
				
				attend <- input[[roles_list[10]]]
				attenddf <- data.frame(meeting_date = rep(input$meeting_date, length(attend)), 
									role = rep("attendee", length(attend)), 
									name = attend
									)
				

				contestchairdf <- data.frame(meeting_date = input$meeting_date, 
									role = "contest_chair", 
									name = input[[roles_list[11]]]
									)
				

				judges <- input[[roles_list[12]]]
				judgesdf <- data.frame(meeting_date = rep(input$meeting_date, length(judges)), 
									role = rep("contest_judge", length(judges)), 
									name = judges
									)
				

				if(is.na(as.numeric(input$guests))){
					guestsn <- 0
				}else{
					guestsn <- input$guests
				}

				
				guestsdf <- data.frame(meeting_date = rep(input$meeting_date, guestsn), 
										role = rep("guest", guestsn), 
										name = rep("guest", guestsn)
										)	
				

				meetingdf <- rbind(rolesdf, speakersdf, attenddf, contestchairdf, judgesdf, guestsdf)

				## save attendence info
				
				sqlSave(tm, subset(meetingdf, name != ""), 'meetings', append = TRUE, varTypes = c(meeting_date = "date", role = "varchar", name = "varchar"), colnames = FALSE, rownames = FALSE)
				

				not_in_db <- setdiff(meetingdf$name, memdb)
				# if(length(not_in_db) > 0){
				# 	add_mem <- data.frame(name = not_in_db, member_since = rep(input$meeting_date, length(not_in_db)), status = rep("guest", length(not_in_db)))
				# 	sqlSave(tm, add_mem, "members", append = TRUE, varTypes = c(name = "varchar", member_since = "date", status = "varchar"), colnames = FALSE, rowname = FALSE)
				# }
	
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
										date = rep(input$meeting_date, length(speeches))
										)
				
				
				
				sqlSave(tm, speechesdf, "speeches", varTypes = c(name = "varchar", date = "date", speech_number = "varchar"), colnames = FALSE, rowname = FALSE, append = TRUE)
				

				## collect award info:`
				bs <- input$bs
				be <- input$be
				btt <- input$btt

				awardlist <- replace_null(list(bs, be, btt))

				award_date_rep <- length(awardlist[[1]]) + length(awardlist[[2]]) + length(awardlist[[3]])

				awardsdf <- data.frame(award = c(rep("best_speaker", length(awardlist[[1]])), rep("best_eavluator", length(awardlist[[2]])), rep("best_tt", length(awardlist[[3]]))), 
											name = unlist(awardlist),
											award_date = rep(input$meeting_date, award_date_rep)
									)
				sqlSave(tm, subset(awardsdf, name != ""), 'awards', append = TRUE, rownames = FALSE, varTypes = c(award = "varchar", name = "varchar", award_date = "date"))

				output$formSubmitted <- reactive({ TRUE })
			})
		}	
	})
	
	observe({
		if(is.null(input$report_for)){
			output$choose_meet_message <- renderText({"Please choose a meeting date."})
		}else{
			report_qry <- sprintf("SELECT role, name FROM meetings WHERE meeting_date = '%s' AND name != 'guest'", as.Date(input$report_for, "%B %d, %Y"))
			report_dat <- sqlQuery(tm, report_qry)	
			output$sec_report <- renderTable(report_dat)
		}
	})

})
