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
		add_tooltip(function(data){paste0("Meeting Date:", data$date_long, "<br>", data$`factor(member)`, ": ", data$Freq)}, "hover") %>%
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

				roles <- data.frame(meeting_date = rep(input$meeting_date, 1:7),
									role = roles_list[1:7, 
									name = memb)


				### save attendence info
				# sqlSave(tm, attend, 'meetings', append = TRUE, rownames = FALSE, nastring = NULL)

				## collect speech info
				speech_info_list <- lapply(speaker_fields, function(x) x <- input[[x]])
				speech_info_list <- lapply(speech_info_list, function(x){
					if(x == ""){
						x <- gsub("", "NA, NA", x)
					}else{
						return(x)
					}
				})
				speech_num <- unlist(lapply(speech_info_list, function(x) strsplit(x, ",")[[1]][1]))
				title <- unlist(lapply(speech_info_list, function(x) strsplit(x, ",")[[1]][2]))
				speeches_df <- data.frame(
					name = c(input$Speaker1, input$Speaker2, input$Speaker3, input$Speaker4, input$Speaker5), 
					speech_num = speech_num, 
					title = title,
					speech_date = input$meeting_date
				)
				speeches_df <- subset(speeches_df, name != "Not Applicable")

				## save speech info to database
				# sqlSave(tm, speeches_df, 'speeches', append = TRUE, rownames = FALSE)

				### collect award info:
				awardsdf <- data.frame(
					award = awards_list, 
					name = c(input$bs, input$be, input$btt), 
					award_date = rep(input$meeting_date, 3)
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
