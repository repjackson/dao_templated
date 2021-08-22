if Meteor.isClient
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    Router.route '/group/:doc_id/edit', (->
        @layout 'layout'
        @render 'group_edit'
        ), name:'group_edit'
    Router.route '/group/:doc_id', (->
        @layout 'layout'
        @render 'group_view'
        ), name:'group_view'



    Template.groups.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'group'
        @autorun -> Meteor.subscribe('groups',
            Session.get('view_complete')
            Session.get('assigned_to')
            picked_tags.array()
            Session.get('group_view_key')
            Session.get('group_view_direction')
            
            )
        # @autorun => Meteor.subscribe 'model_docs', 'group'
        # @autorun => Meteor.subscribe 'model_docs', 'groups_stats'
        # @autorun => Meteor.subscribe 'current_groups'
        
    Template.groups.events
        'click .clear_filter': ->
            Session.set('view_complete', null)
            Session.set('assigned_to', null)
        
        'click .your_incomplete': ->
            Session.set('view_complete', false)
            Session.set('assigned_to', Meteor.user().username)
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_group': (e,t)->
            new_group_id =
                Docs.insert
                    model:'task'
            Session.set('editing_task', true)
            Session.set('picked_task_id', new_task_id)
            Router.go "/task/#{new_task_id}/edit"
        'click .unselect_task': ->
            Session.set('picked_task_id', null)

    Template.groups.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        picked_task_doc: ->
            Docs.findOne Session.get('picked_task_id')
        current_groups: ->
            Docs.find
                model:'task'
                # current:true
        groups_stats_doc: ->
            Docs.findOne
                model:'groups_stats'
        groups: ->
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
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/task/#{@_id}/"
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
        'click .add_group_item': ->
            new_mi_id = Docs.insert
                model:'group_item'
            Router.go "/group/#{_id}/edit"
    Template.group_card_template.helpers
        group_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('picked_group_id', @_id)
                classes += ' inverted blue'
            classes
        group_list: ->
            Docs.findOne
                model:'group_list'
                _id: @group_list_id


    Template.group_card_template.events
        'dblclick .select_group': (e,t)->
            $(e.currentTarget).closest('.item').transition('fly right', 500)
            Router.go "/group/#{@_id}/"
        'click .select_group': ->
            if Session.equals('picked_group_id',@_id)
                Session.set 'picked_group_id', null
            else
                Session.set 'picked_group_id', @_id
        'click .goto_group': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/group/#{@_id}/"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_group_stats: (group_id)->
            group = Docs.findOne group_id
            reservations = Docs.find({model:'reservation', group_id:group_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_group_hours = 0
            average_group_duration = 0

            # shorgroup_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_group_hours += parseFloat(res.hour_duration)

            average_group_cost = total_earnings/reservation_count
            average_group_duration = total_group_hours/reservation_count

            Docs.update group_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_group_hours: total_group_hours.toFixed(0)
                    average_group_cost: average_group_cost.toFixed(0)
                    average_group_duration: average_group_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header group ranking #reservations
            # .ui.small.header group ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg group time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'groups', (
        view_complete=false
        assigned_to=null
        picked_tags=[]
        group_sort_key='_timestamp'
        group_sort_direction=-1
        )->
        # user = Meteor.users.findOne @userId
        self = @
        match = {}
        if view_complete
            match.complete = true
        if assigned_to
            match.assigned_to_usernames = $in: [assigned_to]
            
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'group'
        match.app = 'bc'
        Docs.find match, 
            sort:
                "#{group_sort_key}": group_sort_direction
        
        
        
        
if Meteor.isClient
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'group_list'
    Template.group_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.group_edit.events
        'click .clear_group_list': ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.update group._id,
                $unset:group_list_id:1
    Template.group_edit.helpers
        group_list: ->
            group = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: group.group_list_id
                model:'group_list'
        choices: ->
            Docs.find
                model:'choice'
                group_id:@_id
    Template.group_edit.events
        
        
        
        
        
if Meteor.isClient
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'model_docs', 'group_list'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'time_session'
    Template.group_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.group_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                group_id:Router.current().params.doc_id
        subgroups: ->
            Docs.find
                model:'group'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'group'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    group_id: Router.current().params.doc_id
            if my_answer_session
                false
            else
                true

    Template.group_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                group_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subgroup': ->
            Docs.insert
                model:'group'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked group complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked group incomplete"


        'click .goto_groups': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/groups"
            , 500



if Meteor.isClient
    @picked_tags = new ReactiveArray []

    Template.group_cloud.onCreated ->
        @autorun -> Meteor.subscribe('group_tags',
            picked_tags.array()
            Session.get('view_complete')
            Session.get('view_incomplete')

            )

    Template.group_cloud.helpers
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
            picked_tags.array()


    Template.group_cloud.events
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
            picked_tags.push doc.name
            $('#search').val ''

        'click #add': ->
            Meteor.call 'add', (err,id)->
                Router.go "/edit/#{id}"


if Meteor.isServer
    Meteor.publish 'group_tags', (
        picked_tags
        view_complete
        view_incomplete
        )->
        self = @
        match = {}
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'group'
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


        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()
        