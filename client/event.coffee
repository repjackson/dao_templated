# if Meteor.isClient
#     Router.route '/events', (->
#         @render 'events'
#         ), name:'events'
#     Router.route '/user/:username/events', (->
#         @render 'user_events'
#         ), name:'user_events'

#     Template.events.onCreated ->
#         @autorun -> Meteor.subscribe 'model_docs', 'event'
#         # @autorun -> Meteor.subscribe 'events',
#         #     Session.get('event_status_filter')
#         # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
#         # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100
#     Template.events.events
#         'click .add_event': ->
#             new_id = 
#                 Docs.insert 
#                     model:'event'
#             Router.go "/event/#{new_id}/edit"

#     Template.events.events
#         'click .new_event': ->
#             new_id = 
#                 Docs.insert 
#                     model:'event'
#             Router.go "/event/#{new_id}/edit"


#     Template.events.helpers
#         events: ->
#             match = {model:'event'}
#             if Session.get('event_status_filter')
#                 match.status = Session.get('event_status_filter')
#             if Session.get('event_delivery_filter')
#                 match.delivery_method = Session.get('event_sort_filter')
#             if Session.get('event_sort_filter')
#                 match.delivery_method = Session.get('event_sort_filter')
#             Docs.find match,
#                 sort: _timestamp:-1


# if Meteor.isClient
#     Router.route '/event/:doc_id', (->
#         @layout 'layout'
#         @render 'event_view'
#         ), name:'event_view'


#     Template.event_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'product_by_event_id', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'event_things', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'review_from_event_id', Router.current().params.doc_id


#     Template.event_view.events
#         'click .mark_viewed': ->
#             # if confirm 'mark viewed?'
#             Docs.update Router.current().params.doc_id, 
#                 $set:
#                     runner_viewed: true
#                     runner_viewed_timestamp: Date.now()
#                     runner_username: Meteor.user().username
#                     status: 'viewed' 
      
#         'click .mark_preparing': ->
#             # if confirm 'mark mark_preparing?'
#             Docs.update Router.current().params.doc_id, 
#                 $set:
#                     preparing: true
#                     preparing_timestamp: Date.now()
#                     status: 'preparing' 
       
#         'click .delete_event': ->
#             thing_count = Docs.find(model:'thing').count()
#             if confirm "delete? #{thing_count} things still"
#                 Docs.remove @_id
#                 Router.go "/events"
    
#         'click .mark_ready': ->
#             if confirm 'mark ready?'
#                 Docs.insert 
#                     model:'event_event'
#                     event_id: Router.current().params.doc_id
#                     event_status:'ready'

#         'click .add_review': ->
#             Docs.insert 
#                 model:'event_review'
#                 event_id: Router.current().params.doc_id
                
                
#         'click .review_positive': ->
#             Docs.update @_id,
#                 $set:
#                     rating:1
#         'click .review_negative': ->
#             Docs.update @_id,
#                 $set:
#                     rating:-1

#     Template.event_view.helpers
#         event_review: ->
#             Docs.findOne 
#                 model:'event_review'
#                 event_id:Router.current().params.doc_id
    
#         can_event: ->
#             # if StripeCheckout
#             unless @_author_id is Meteor.userId()
#                 event_count =
#                     Docs.find(
#                         model:'event'
#                         event_id:@_id
#                     ).count()
#                 if event_count is @servings_amount
#                     false
#                 else
#                     true
#             # else
#             #     false




# if Meteor.isServer
#     Meteor.publish 'events', (event_id, status)->
#         # event = Docs.findOne event_id
#         match = {model:'event'}
#         if status 
#             match.status = status

#         Docs.find match
        
#     Meteor.publish 'review_from_event_id', (event_id)->
#         # event = Docs.findOne loss_id
#         # match = {model:'loss'}
#         Docs.find 
#             model:'loss_review'
#             loss_id:loss_id
        
#     Meteor.publish 'product_by_loss_id', (loss_id)->
#         loss = Docs.findOne loss_id
#         Docs.find
#             _id: loss.ref_id
#     Meteor.publish 'loss_things', (loss_id)->
#         loss = Docs.findOne loss_id
#         Docs.find
#             model:'thing'
#             loss_id: loss_id

#     # Meteor.methods
#         # loss_loss: (loss_id)->
#         #     loss = Docs.findOne loss_id
#         #     Docs.insert
#         #         model:'loss'
#         #         loss_id: loss._id
#         #         loss_price: loss.price_per_serving
#         #         buyer_id: Meteor.userId()
#         #     Meteor.users.update Meteor.userId(),
#         #         $inc:credit:-loss.price_per_serving
#         #     Meteor.users.update loss._author_id,
#         #         $inc:credit:loss.price_per_serving
#         #     Meteor.call 'calc_loss_data', loss_id, ->


# if Meteor.isServer
#     Meteor.publish 'product_from_loss_id', (loss_id)->
#         loss = Docs.findOne loss_id
#         Docs.find
#             model:'product'
#             _id: loss.ref_id


# if Meteor.isClient
#     Router.route '/event/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'event_edit'
#         ), name:'event_edit'



#     Template.event_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'model_docs', 'food', ->
#         # @autorun => Meteor.subscribe 'model_docs', 'source'

#     Template.event_edit.onRendered ->
#         # Meteor.setTimeout ->
#         #     today = new Date()
#         #     $('#availability')
#         #         .calendar({
#         #             inline:true
#         #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
#         #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
#         #         })
#         # , 2000

#     Template.event_edit.helpers
#         unpicked_refs: ->
#             current_event_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find   
#                 model:'food'
#                 _id:$ne:current_event_doc.ref_id
#         picked_ref: ->
#             current_event_doc = Docs.findOne Router.current().params.doc_id
#             Docs.findOne 
#                 model:'food'
#                 _id:current_event_doc.ref_id
#         # balance_after_purchase: ->
#         #     Meteor.user().points - @purchase_amount
#         # percent_difference: ->
#         #     balance_after_purchase = 
#         #         Meteor.user().points - @purchase_amount
#         #     # difference
#         #     @purchase_amount/Meteor.user().points
#     Template.event_edit.events
#         'click .pick_ref': (e,t)->
#             current_event_doc = Docs.findOne Router.current().params.doc_id
#             Docs.update Router.current().params.doc_id,
#                 $set:ref_id:@_id
#         'click .clear_ref': (e,t)->
#             current_event_doc = Docs.findOne Router.current().params.doc_id
#             Docs.update Router.current().params.doc_id,
#                 $unset:ref_id:1

#         # 'click .complete_event': (e,t)->
#         #     console.log @
#         #     Session.set('eventing',true)
#         #     if @purchase_amount
#         #         if Meteor.user().points and @purchase_amount < Meteor.user().points
#         #             Meteor.call 'complete_event', @_id, =>
#         #                 Router.go "/ref/#{@ref_id}"
#         #                 Session.set('eventing',false)
#         #         else 
#         #             alert "not enough points"
#         #             Router.go "/user/#{Meteor.user().username}/points"
#         #             Session.set('eventing',false)
#         #     else 
#         #         alert 'no purchase amount'
            
            
#         'click .delete_event': ->
#             Docs.remove @_id
#             Router.go "/"
