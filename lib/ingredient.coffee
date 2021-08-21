if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'
    Router.route '/ingredient/:doc_id', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'



    Template.ingredients.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun -> Meteor.subscribe('ingredients',
            Session.get('view_complete')
            Session.get('assigned_to')
            picked_tags.array()
            Session.get('ingredient_view_key')
            Session.get('ingredient_view_direction')
            
            )
        # @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        # @autorun => Meteor.subscribe 'model_docs', 'ingredients_stats'
        # @autorun => Meteor.subscribe 'current_ingredients'
        
    Template.ingredients.events
        'click .clear_filter': ->
            Session.set('view_complete', null)
            Session.set('assigned_to', null)
        
        'click .your_incomplete': ->
            Session.set('view_complete', false)
            Session.set('assigned_to', Meteor.user().username)
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_ingredient': (e,t)->
            new_ingredient_id =
                Docs.insert
                    model:'ingredient'
            Session.set('editing_ingredient', true)
            Session.set('picked_ingredient_id', new_ingredient_id)
            Router.go "/ingredient/#{new_ingredient_id}/edit"
        'click .unselect_ingredient': ->
            Session.set('picked_ingredient_id', null)

    Template.ingredients.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        picked_ingredient_doc: ->
            Docs.findOne Session.get('picked_ingredient_id')
        current_ingredients: ->
            Docs.find
                model:'ingredient'
                # current:true
        ingredients_stats_doc: ->
            Docs.findOne
                model:'ingredients_stats'
        ingredients: ->
            Docs.find
                model:'ingredient'




    Template.picked_ingredient.events
        'click .delete_ingredient': ->
            if confirm 'delete ingredient?'
                Docs.remove @_id
                Session.set('picked_ingredient_id', null)
        'click .save_ingredient': ->
            Session.set('editing_ingredient', false)
        'click .edit_ingredient': ->
            Session.set('editing_ingredient', true)
        'click .goto_ingredient': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/ingredient/#{@_id}/"
            , 500

    Template.picked_ingredient.helpers
        editing_ingredient: -> Session.get('editing_ingredient')










    Template.ingredient_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.ingredient_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.ingredient_card_template.events
        'click .add_ingredient_item': ->
            new_mi_id = Docs.insert
                model:'ingredient_item'
            Router.go "/ingredient/#{_id}/edit"
    Template.ingredient_card_template.helpers
        ingredient_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('picked_ingredient_id', @_id)
                classes += ' inverted blue'
            classes
        ingredient_list: ->
            Docs.findOne
                model:'ingredient_list'
                _id: @ingredient_list_id


    Template.ingredient_card_template.events
        'dblclick .select_ingredient': (e,t)->
            $(e.currentTarget).closest('.item').transition('fly right', 500)
            Router.go "/ingredient/#{@_id}/"
        'click .select_ingredient': ->
            if Session.equals('picked_ingredient_id',@_id)
                Session.set 'picked_ingredient_id', null
            else
                Session.set 'picked_ingredient_id', @_id
        'click .goto_ingredient': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/ingredient/#{@_id}/"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_ingredient_stats: (ingredient_id)->
            ingredient = Docs.findOne ingredient_id
            reservations = Docs.find({model:'reservation', ingredient_id:ingredient_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_ingredient_hours = 0
            average_ingredient_duration = 0

            # shoringredient_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_ingredient_hours += parseFloat(res.hour_duration)

            average_ingredient_cost = total_earnings/reservation_count
            average_ingredient_duration = total_ingredient_hours/reservation_count

            Docs.update ingredient_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_ingredient_hours: total_ingredient_hours.toFixed(0)
                    average_ingredient_cost: average_ingredient_cost.toFixed(0)
                    average_ingredient_duration: average_ingredient_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header ingredient ranking #reservations
            # .ui.small.header ingredient ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg ingredient time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'ingredients', (
        view_complete=false
        assigned_to=null
        picked_tags=[]
        ingredient_sort_key='_timestamp'
        ingredient_sort_direction=-1
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
        match.model = 'ingredient'
        match.app = 'bc'
        Docs.find match, 
            sort:
                "#{ingredient_sort_key}": ingredient_sort_direction
        
        
        
        
if Meteor.isClient
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient_list'
    Template.ingredient_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.ingredient_edit.events
        'click .clear_ingredient_list': ->
            ingredient = Docs.findOne Router.current().params.doc_id
            Docs.update ingredient._id,
                $unset:ingredient_list_id:1
    Template.ingredient_edit.helpers
        ingredient_list: ->
            ingredient = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: ingredient.ingredient_list_id
                model:'ingredient_list'
        choices: ->
            Docs.find
                model:'choice'
                ingredient_id:@_id
    Template.ingredient_edit.events
        
        
        
        
        
if Meteor.isClient
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'model_docs', 'ingredient_list'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'time_session'
    Template.ingredient_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.ingredient_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                ingredient_id:Router.current().params.doc_id
        subingredients: ->
            Docs.find
                model:'ingredient'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    ingredient_id: Router.current().params.doc_id
            if my_answer_session
                false
            else
                true

    Template.ingredient_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                ingredient_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subingredient': ->
            Docs.insert
                model:'ingredient'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked ingredient complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked ingredient incomplete"


        'click .goto_ingredients': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/ingredients"
            , 500



if Meteor.isClient
    @picked_tags = new ReactiveArray []

    Template.ingredient_cloud.onCreated ->
        @autorun -> Meteor.subscribe('ingredient_tags',
            picked_tags.array()
            Session.get('view_complete')
            Session.get('view_incomplete')

            )

    Template.ingredient_cloud.helpers
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


    Template.ingredient_cloud.events
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
    Meteor.publish 'ingredient_tags', (
        picked_tags
        view_complete
        view_incomplete
        )->
        self = @
        match = {}
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        # if filter then match.model = filter
        match.model = 'ingredient'
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
        