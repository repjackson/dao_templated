Template.transfer_view.onRendered ->

Router.route '/transfer/:doc_id', (->
    @layout 'layout'
    @render 'transfer_view'
    ), name:'transfer_view'


Template.transfer_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.transfer_view.onCreated ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'target_from_transfer_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'all_users'
    # @autorun => Meteor.subscribe 'product_by_transfer_id', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'transfer_things', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'review_from_transfer_id', Router.current().params.doc_id


Template.transfer_view.events
    'click .flat_tag': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        Router.go '/'
    # 'click .mark_viewed': ->
    #     # if confirm 'mark viewed?'
    #     Docs.update Router.current().params.doc_id, 
    #         $set:
    #             runner_viewed: true
    #             runner_viewed_timestamp: Date.now()
    #             runner_username: Meteor.user().username
    #             status: 'viewed' 
  