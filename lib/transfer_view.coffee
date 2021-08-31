if Meteor.isClient        
    Template.transfer_view.onRendered ->

    Router.route '/transfer/:doc_id', (->
        @layout 'layout'
        @render 'transfer_view'
        ), name:'transfer_view'


    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        # @autorun => Meteor.subscribe 'product_by_transfer_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'transfer_things', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'review_from_transfer_id', Router.current().params.doc_id


    Template.transfer_view.events
        # 'click .mark_viewed': ->
        #     # if confirm 'mark viewed?'
        #     Docs.update Router.current().params.doc_id, 
        #         $set:
        #             runner_viewed: true
        #             runner_viewed_timestamp: Date.now()
        #             runner_username: Meteor.user().username
        #             status: 'viewed' 
      

    Template.transfer_view.helpers
        transfer_review: ->
            Docs.findOne 
                model:'transfer_review'
                transfer_id:Router.current().params.doc_id
    
        can_transfer: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                transfer_count =
                    Docs.find(
                        model:'transfer'
                        transfer_id:@_id
                    ).count()
                if transfer_count is @servings_amount
                    false
                else
                    true
            # else
            #     false


