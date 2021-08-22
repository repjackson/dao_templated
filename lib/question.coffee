if Meteor.isClient
    Router.route '/questions', (->
        @layout 'layout'
        @render 'questions'
        ), name:'questions'
    Router.route '/question/:doc_id/edit', (->
        @layout 'layout'
        @render 'question_edit'
        ), name:'question_edit'
    Router.route '/question/:doc_id', (->
        @layout 'layout'
        @render 'question_view'
        ), name:'question_view'



    Template.questions.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe('questions',
            Session.get('view_complete')
            Session.get('assigned_to')
            picked_tags.array()
            Session.get('question_view_key')
            Session.get('question_view_direction')
            
            )
        # @autorun => Meteor.subscribe 'model_docs', 'question'
        # @autorun => Meteor.subscribe 'model_docs', 'questions_stats'
        # @autorun => Meteor.subscribe 'current_questions'
        
    Template.questions.events
        'click .clear_filter': ->
            Session.set('view_complete', null)
            Session.set('assigned_to', null)
        
        'click .your_incomplete': ->
            Session.set('view_complete', false)
            Session.set('assigned_to', Meteor.user().username)
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_question': (e,t)->
            new_question_id =
                Docs.insert
                    model:'question'
            Session.set('editing_question', true)
            Session.set('picked_question_id', new_question_id)
            Router.go "/question/#{new_question_id}/edit"
        'click .unselect_question': ->
            Session.set('picked_question_id', null)

    Template.questions.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        picked_question_doc: ->
            Docs.findOne Session.get('picked_question_id')
        current_questions: ->
            Docs.find
                model:'question'
                # current:true
        questions_stats_doc: ->
            Docs.findOne
                model:'questions_stats'
        questions: ->
            Docs.find
                model:'question'



    Template.question_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.question_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.question_card_template.events
        'click .add_question_item': ->
            new_mi_id = Docs.insert
                model:'question_item'
            Router.go "/question/#{_id}/edit"
    Template.question_card_template.helpers
        question_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('picked_question_id', @_id)
                classes += ' inverted blue'
            classes
        question_list: ->
            Docs.findOne
                model:'question_list'
                _id: @question_list_id


    Template.question_card_template.events
        'dblclick .select_question': (e,t)->
            $(e.currentTarget).closest('.item').transition('fly right', 500)
            Router.go "/question/#{@_id}/"
        'click .select_question': ->
            if Session.equals('picked_question_id',@_id)
                Session.set 'picked_question_id', null
            else
                Session.set 'picked_question_id', @_id
        'click .goto_question': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/question/#{@_id}/"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_question_stats: (question_id)->
            question = Docs.findOne question_id
            reservations = Docs.find({model:'reservation', question_id:question_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_question_hours = 0
            average_question_duration = 0

            # shorquestion_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_question_hours += parseFloat(res.hour_duration)

            average_question_cost = total_earnings/reservation_count
            average_question_duration = total_question_hours/reservation_count

            Docs.update question_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_question_hours: total_question_hours.toFixed(0)
                    average_question_cost: average_question_cost.toFixed(0)
                    average_question_duration: average_question_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header question ranking #reservations
            # .ui.small.header question ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg question time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'questions', (
        view_complete=false
        assigned_to=null
        picked_tags=[]
        question_sort_key='_timestamp'
        question_sort_direction=-1
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
        match.model = 'question'
        match.app = 'bc'
        Docs.find match, 
            sort:
                "#{question_sort_key}": question_sort_direction
        
        
        
        
if Meteor.isClient
    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'question_choice'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id

    Template.question_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.question_edit.events
        'click .add_choice': ->
            question = Docs.findOne Router.current().params.doc_id
            Docs.insert
                model:'question_choice'
                parent_id:Router.current().params.doc_id
    Template.question_edit.helpers
        choice_docs: ->
            Docs.find 
                model:'question_choice'
                parent_id:Router.current().params.doc_id
    Template.question_edit.events
        
        
        
        
        
if Meteor.isClient
    Template.question_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'question_choice'
    Template.question_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.question_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                question_id:Router.current().params.doc_id
        subquestions: ->
            Docs.find
                model:'question'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'question'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    question_id: Router.current().params.doc_id
            if my_answer_session
                false
            else
                true

    Template.question_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                question_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subquestion': ->
            Docs.insert
                model:'question'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked question complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked question incomplete"


        'click .goto_questions': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/questions"
            , 500


if Meteor.isServer
    Meteor.publish 'question_tags', (
        picked_tags
        view_complete
        view_incomplete
        )->
        self = @
        match = {}
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'question'
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
        