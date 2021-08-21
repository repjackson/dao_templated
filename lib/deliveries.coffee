if Meteor.isClient
    Router.route '/deliveries', (->
        @layout 'layout'
        @render 'deliveries'
        ), name:'deliveries'
    Router.route '/delivery/:doc_id/edit', (->
        @layout 'layout'
        @render 'delivery_edit'
        ), name:'delivery_edit'
    Router.route '/delivery/:doc_id', (->
        @layout 'layout'
        @render 'delivery_view'
        ), name:'delivery_view'



    Template.deliveries.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'delivery'
        @autorun -> Meteor.subscribe('deliveries',
            Session.get('view_complete')
            Session.get('assigned_to')
            picked_tags.array()
            Session.get('delivery_view_key')
            Session.get('delivery_view_direction')
            
            )
        # @autorun => Meteor.subscribe 'model_docs', 'delivery'
        # @autorun => Meteor.subscribe 'model_docs', 'deliveries_stats'
        # @autorun => Meteor.subscribe 'current_deliveries'
        
    Template.deliveries.events
        'click .clear_filter': ->
            Session.set('view_complete', null)
            Session.set('assigned_to', null)
        
        'click .your_incomplete': ->
            Session.set('view_complete', false)
            Session.set('assigned_to', Meteor.user().username)
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_delivery': (e,t)->
            new_delivery_id =
                Docs.insert
                    model:'delivery'
            Session.set('editing_delivery', true)
            Session.set('picked_delivery_id', new_delivery_id)
            Router.go "/delivery/#{new_delivery_id}/edit"
        'click .unselect_delivery': ->
            Session.set('picked_delivery_id', null)

    Template.deliveries.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        picked_delivery_doc: ->
            Docs.findOne Session.get('picked_delivery_id')
        current_deliveries: ->
            Docs.find
                model:'delivery'
                # current:true
        deliveries_stats_doc: ->
            Docs.findOne
                model:'deliveries_stats'
        deliveries: ->
            Docs.find
                model:'delivery'




    # Template.picked_delivery.events
    #     'click .delete_delivery': ->
    #         if confirm 'delete delivery?'
    #             Docs.remove @_id
    #             Session.set('picked_delivery_id', null)
    #     'click .save_delivery': ->
    #         Session.set('editing_delivery', false)
    #     'click .edit_delivery': ->
    #         Session.set('editing_delivery', true)
    #     'click .goto_delivery': (e,t)->
    #         $(e.currentTarget).closest('.grid').transition('fly right', 500)
    #         Meteor.setTimeout =>
    #             Router.go "/delivery/#{@_id}/"
    #         , 500

    # Template.picked_delivery.helpers
    #     editing_delivery: -> Session.get('editing_delivery')










    # Template.delivery_card_template.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000
    # Template.delivery_card_template.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'log_events'
    # Template.delivery_card_template.events
    #     'click .add_delivery_item': ->
    #         new_mi_id = Docs.insert
    #             model:'delivery_item'
    #         Router.go "/delivery/#{_id}/edit"
    # Template.delivery_card_template.helpers
    #     delivery_segment_class: ->
    #         classes=''
    #         if @complete
    #             classes += ' green'
    #         if Session.equals('picked_delivery_id', @_id)
    #             classes += ' inverted blue'
    #         classes
    #     delivery_list: ->
    #         Docs.findOne
    #             model:'delivery_list'
    #             _id: @delivery_list_id


    # Template.delivery_card_template.events
    #     'dblclick .select_delivery': (e,t)->
    #         $(e.currentTarget).closest('.item').transition('fly right', 500)
    #         Router.go "/delivery/#{@_id}/"
    #     'click .select_delivery': ->
    #         if Session.equals('picked_delivery_id',@_id)
    #             Session.set 'picked_delivery_id', null
    #         else
    #             Session.set 'picked_delivery_id', @_id
    #     'click .goto_delivery': (e,t)->
    #         $(e.currentTarget).closest('.grid').transition('fade right', 500)
    #         Meteor.setTimeout =>
    #             Router.go "/delivery/#{@_id}/"
    #         , 500







if Meteor.isServer
    Meteor.methods
        refresh_delivery_stats: (delivery_id)->
            delivery = Docs.findOne delivery_id
            reservations = Docs.find({model:'reservation', delivery_id:delivery_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_delivery_hours = 0
            average_delivery_duration = 0

            # shordelivery_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_delivery_hours += parseFloat(res.hour_duration)

            average_delivery_cost = total_earnings/reservation_count
            average_delivery_duration = total_delivery_hours/reservation_count

            Docs.update delivery_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_delivery_hours: total_delivery_hours.toFixed(0)
                    average_delivery_cost: average_delivery_cost.toFixed(0)
                    average_delivery_duration: average_delivery_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header delivery ranking #reservations
            # .ui.small.header delivery ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg delivery time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'deliveries', (
        view_complete=false
        assigned_to=null
        picked_tags=[]
        delivery_sort_key='_timestamp'
        delivery_sort_direction=-1
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
        match.model = 'delivery'
        match.app = 'bc'
        Docs.find match, 
            sort:
                "#{delivery_sort_key}": delivery_sort_direction
        
        
        
        
if Meteor.isClient
    Template.delivery_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'delivery_list'
    Template.delivery_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.delivery_edit.events
        'click .clear_delivery_list': ->
            delivery = Docs.findOne Router.current().params.doc_id
            Docs.update delivery._id,
                $unset:delivery_list_id:1
    Template.delivery_edit.helpers
        delivery_list: ->
            delivery = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: delivery.delivery_list_id
                model:'delivery_list'
        choices: ->
            Docs.find
                model:'choice'
                delivery_id:@_id
    Template.delivery_edit.events
        
        
        
        
        
if Meteor.isClient
    Template.delivery_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'model_docs', 'delivery_list'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'time_session'
    Template.delivery_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.delivery_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                delivery_id:Router.current().params.doc_id
        subdeliveries: ->
            Docs.find
                model:'delivery'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'delivery'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    delivery_id: Router.current().params.doc_id
            if my_answer_session
                false
            else
                true

    Template.delivery_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                delivery_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subdelivery': ->
            Docs.insert
                model:'delivery'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked delivery complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked delivery incomplete"


        'click .goto_deliveries': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/deliveries"
            , 500



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
        