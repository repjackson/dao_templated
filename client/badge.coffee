if Meteor.isClient
    Router.route '/badges', (->
        @render 'badges'
        ), name:'badges'
    Router.route '/user/:username/badges', (->
        @render 'user_badges'
        ), name:'user_badges'

    Template.badges.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'badge'
        # @autorun -> Meteor.subscribe 'badges',
        #     Session.get('badge_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100
    Template.badges.events
        'click .add_badge': ->
            new_id = 
                Docs.insert 
                    model:'badge'
            Router.go "/badge/#{new_id}/edit"



    Template.badges.helpers
        badges: ->
            match = {model:'badge'}
            if Session.get('badge_status_filter')
                match.status = Session.get('badge_status_filter')
            if Session.get('badge_delivery_filter')
                match.delivery_method = Session.get('badge_sort_filter')
            if Session.get('badge_sort_filter')
                match.delivery_method = Session.get('badge_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/badge/:doc_id', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'


    Template.badge_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_badge_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'badge_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_badge_id', Router.current().params.doc_id


    Template.badge_view.events
        'click .mark_viewed': ->
            # if confirm 'mark viewed?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    runner_viewed: true
                    runner_viewed_timestamp: Date.now()
                    runner_username: Meteor.user().username
                    status: 'viewed' 
      
        'click .mark_preparing': ->
            # if confirm 'mark mark_preparing?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    preparing: true
                    preparing_timestamp: Date.now()
                    status: 'preparing' 
       
        'click .mark_prepared': ->
            # if confirm 'mark prepared?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    prepared: true
                    prepared_timestamp: Date.now()
                    status: 'prepared' 
     
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
        
        'click .mark_delivering': ->
            # if confirm 'mark delivering?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivering: true
                    delivering_timestamp: Date.now()
                    status: 'delivering' 
      
        'click .mark_delivered': ->
            # if confirm 'mark delivered?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivered: true
                    delivered_timestamp: Date.now()
                    status: 'delivered' 
      
        'click .delete_badge': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/badges"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'badge_event'
                    badge_id: Router.current().params.doc_id
                    badge_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'badge_review'
                badge_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.badge_view.helpers
        badge_review: ->
            Docs.findOne 
                model:'badge_review'
                badge_id:Router.current().params.doc_id
    
        can_badge: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                badge_count =
                    Docs.find(
                        model:'badge'
                        badge_id:@_id
                    ).count()
                if badge_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'badges', (badge_id, status)->
        # badge = Docs.findOne badge_id
        match = {model:'badge'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_badge_id', (badge_id)->
        # badge = Docs.findOne badge_id
        # match = {model:'badge'}
        Docs.find 
            model:'badge_review'
            badge_id:badge_id
        
    Meteor.publish 'product_by_badge_id', (badge_id)->
        badge = Docs.findOne badge_id
        Docs.find
            _id: badge.product_id
    Meteor.publish 'badge_things', (badge_id)->
        badge = Docs.findOne badge_id
        Docs.find
            model:'thing'
            badge_id: badge_id

    # Meteor.methods
        # badge_badge: (badge_id)->
        #     badge = Docs.findOne badge_id
        #     Docs.insert
        #         model:'badge'
        #         badge_id: badge._id
        #         badge_price: badge.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-badge.price_per_serving
        #     Meteor.users.update badge._author_id,
        #         $inc:credit:badge.price_per_serving
        #     Meteor.call 'calc_badge_data', badge_id, ->


if Meteor.isServer
    Meteor.publish 'product_from_badge_id', (badge_id)->
        badge = Docs.findOne badge_id
        Docs.find
            model:'product'
            _id: badge.product_id


if Meteor.isClient
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'



    Template.badge_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.badge_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.badge_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.badge_edit.events
        'click .complete_badge': (e,t)->
            console.log @
            Session.set('badgeing',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_badge', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('badgeing',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('badgeing',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_badge': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"
