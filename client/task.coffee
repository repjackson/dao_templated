if Meteor.isClient
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'
    Router.route '/task/:doc_id/view', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'



    Template.tasks.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'task'
        @autorun -> Meteor.subscribe('tasks',
            picked_tags.array()
            # Session.get('view_complete')
            # Session.get('view_incomplete')
            )
        @autorun => Meteor.subscribe 'model_docs', 'tasks_stats'
        @autorun => Meteor.subscribe 'current_tasks'
    Template.tasks.events
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_task': (e,t)->
            new_task_id =
                Docs.insert
                    model:'task'
            Session.set('editing_task', true)
            Session.set('picked_task_id', new_task_id)
        'click .unselect_task': ->
            Session.set('picked_task_id', null)

    Template.tasks.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        picked_task_doc: ->
            Docs.findOne Session.get('picked_task_id')
        current_tasks: ->
            Docs.find
                model:'task'
                current:true
        tasks_stats_doc: ->
            Docs.findOne
                model:'tasks_stats'
        tasks: ->
            Docs.find
                model:'task'




    Template.picked_task.events
        'click .delete_task': ->
            if confirm 'delete task?'
                Docs.remove @_id
                Session.set('picked_task_id', null)
        'click .save_task': ->
            Session.set('editing_task', false)
        'click .edit_task': ->
            Session.set('editing_task', true)
        'click .goto_task': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/task/#{@_id}/view"
            , 500

    Template.picked_task.helpers
        editing_task: -> Session.get('editing_task')










    Template.task_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.task_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.task_card_template.events
        'click .add_task_item': ->
            new_mi_id = Docs.insert
                model:'task_item'
            Router.go "/task/#{_id}/edit"
    Template.task_card_template.helpers
        task_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('picked_task_id', @_id)
                classes += ' inverted blue'
            classes
        task_list: ->
            # console.log @
            Docs.findOne
                model:'task_list'
                _id: @task_list_id


    Template.task_card_template.events
        'click .select_task': ->
            if Session.equals('picked_task_id',@_id)
                Session.set 'picked_task_id', null
            else
                Session.set 'picked_task_id', @_id
        'click .goto_task': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/task/#{@_id}/view"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_task_stats: (task_id)->
            task = Docs.findOne task_id
            # console.log task
            reservations = Docs.find({model:'reservation', task_id:task_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_task_hours = 0
            average_task_duration = 0

            # shortask_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_task_hours += parseFloat(res.hour_duration)

            average_task_cost = total_earnings/reservation_count
            average_task_duration = total_task_hours/reservation_count

            Docs.update task_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_task_hours: total_task_hours.toFixed(0)
                    average_task_cost: average_task_cost.toFixed(0)
                    average_task_duration: average_task_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header task ranking #reservations
            # .ui.small.header task ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg task time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'tasks', (
        picked_tags
        # view_complete
        )->
        # user = Meteor.users.findOne @userId
        # console.log picked_tags
        # console.log filter
        self = @
        match = {}
        # if view_complete
        #     match.complete = true
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'task'

        Docs.find match, sort:_timestamp:-1
        
        
        
        
if Meteor.isClient
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'task_list'
    Template.task_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.task_edit.events
        'click .clear_task_list': ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.update task._id,
                $unset:task_list_id:1
    Template.task_edit.helpers
        task_list: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: task.task_list_id
                model:'task_list'
        choices: ->
            Docs.find
                model:'choice'
                task_id:@_id
    Template.task_edit.events
        
        
        
        
        
if Meteor.isClient
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'model_docs', 'task_list'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'time_session'
    Template.task_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.task_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                task_id:Router.current().params.doc_id
        subtasks: ->
            Docs.find
                model:'task'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'task'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            # console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    task_id: Router.current().params.doc_id
            if my_answer_session
                # console.log 'false'
                false
            else
                # console.log 'true'
                true

    Template.task_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                task_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subtask': ->
            Docs.insert
                model:'task'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked task complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked task incomplete"


        'click .goto_tasks': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/tasks"
            , 500



if Meteor.isClient
    @picked_tags = new ReactiveArray []

    Template.task_cloud.onCreated ->
        @autorun -> Meteor.subscribe('task_tags',
            picked_tags.array()
            Session.get('view_complete')
            Session.get('view_incomplete')

            )

    Template.task_cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Results.find { count: $lt: doc_count } else Results.find()

        tag_cloud_class: ->
            button_class = switch
                when @index <= 10 then 'big'
                when @index <= 20 then 'large'
                when @index <= 30 then ''
                when @index <= 40 then 'small'
                when @index <= 50 then 'tiny'
            return button_class

        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Results
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
                ]
        }


        picked_tags: ->
            # model = 'event'
            # console.log "selected_#{model}_tags"
            picked_tags.array()


    Template.task_cloud.events
        'click .select_tag': -> picked_tags.push @name
        'click .unselect_tag': -> picked_tags.remove @valueOf()
        'click #clear_tags': -> picked_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            picked_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                picked_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        picked_tags.pop()

        'autocompleteselect #search': (event, template, doc) ->
            # console.log 'selected ', doc
            picked_tags.push doc.name
            $('#search').val ''

        'click #add': ->
            Meteor.call 'add', (err,id)->
                Router.go "/edit/#{id}"


if Meteor.isServer
    Meteor.publish 'task_tags', (
        picked_tags
        view_complete
        view_incomplete
        )->
        self = @
        match = {}
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'task'
        if view_complete
            match.complete = true

        cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        # console.log 'filter: ', filter
        # console.log 'cloud: ', cloud

        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()
        