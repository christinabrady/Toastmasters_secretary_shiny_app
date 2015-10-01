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
				attend <- input[[roles_list[9]]]
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

				if(length(input$guest) == 0){
					guests <- 0
				}else{
					guests <- as.numeric(input$guest)
				}

				guestsdf <- data.frame(meeting_date = rep(input$meeting_date, guests), 
										role = rep("guest", guests), 
										name = rep("guest", guests)
										)	

				meetingdf <- rbind(rolesdf, speakersdf, attenddf, contestchairdf, judgesdf, guestsdf)

				## save attendence info
				print(subset(meetingdf, name != ""))
				# sqlSave(tm, subset(meetingdf, name != ""), 'meetings', append = TRUE, rownames = FALSE)

				## collect speech info
				speeches <- unlist(strsplit(input$speechesin, ","))
				speechesdf <- data.frame(name = speakers, 
										speech_number = speeches, 
										date = rep(input$meeting_date, length(speeches))
										)
				print(speechesdf)
				
				## collect award info:`
				bs <- input[[awards_list[1]]]
				be <- input[[awards_list[2]]]
				btt <- input[[awards_list[3]]]
				award_date_rep <- length(bs) + length(be) + length(btt)
				awardsdf <- data.frame(award = c(rep("best_speaker", length(bs), rep("best_eavluator", length(be)), rep("best_tt", length(btt)))), 
											name = c(bs, be, btt),
											award_date = rep(input$meeting_date, award_date_rep)
									)
				print(awardsdf)
				### save award info to datebase
				# sqlSave(tm, awardsdf, 'awards', append = TRUE, rownames = FALSE)

				### run list of sqlsave functions:
				# lapply(list(ssave1, ssave2, ssave3), f(x))
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
