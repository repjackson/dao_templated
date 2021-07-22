if Meteor.isClient
    @picked_topup_tags = new ReactiveArray []
    
    Router.route '/topup/:doc_id', (->
        @layout 'layout'
        @render 'topup_view'
        ), name:'topup_view'
            
    Template.topup_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'topup_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'child_groups_from_parent_id', Router.current().params.doc_id,->
 
    Template.topup_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'topup_work', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.topup_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                topup_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.topup_view.helpers
        possible_locations: ->
            topup = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:topup.location_ids
                
        topup_work: ->
            Docs.find 
                model:'work'
                topup_id:Router.current().params.doc_id
                
    Template.topup_edit.helpers
        topup_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            topup = Docs.findOne Router.current().params.doc_id
            if topup.location_ids and @_id in topup.location_ids then 'blue' else 'basic'
            
                
    Template.topup_edit.events
        'click .select_location': ->
            topup = Docs.findOne Router.current().params.doc_id
            if topup.location_ids and @_id in topup.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'topup_work', (topup_id)->
        Docs.find   
            model:'work'
            topup_id:topup_id
    # Meteor.publish 'work_topup', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'topup'
    #         _id: work.topup_id
            
            
    Meteor.publish 'user_sent_topup', (username)->
        Docs.find   
            model:'topup'
            _author_username:username
    Meteor.publish 'product_topup', (product_id)->
        Docs.find   
            model:'topup'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/topup/:doc_id/edit', (->
        @layout 'layout'
        @render 'topup_edit'
        ), name:'topup_edit'



    Template.topup_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.topup_edit.events
        'click .send_topup': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    topup = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update topup._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'topup sent',
                        ''
                        'success'
                    Router.go "/topup/#{@_id}/"
                    )
            )

        'click .delete_topup':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/topups"
            
    Template.topup_edit.helpers
        all_shop: ->
            Docs.find
                model:'topup'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id
                
if Meteor.isClient
    Router.route '/location/:doc_id', (->
        @layout 'layout'
        @render 'location_view'
        ), name:'location_view'
    # Router.route '/locations', (->
    #     @layout 'layout'
    #     @render 'locations'
    #     ), name:'locations'
    
            
    # Template.locations.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'location', ->
    
    Template.location_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'location_work', Router.current().params.doc_id, ->
    Template.location_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'location_work', Router.current().params.doc_id, ->
    


    # Template.locations.events
    #     'click .add_location': ->
    #         new_id = Docs.insert 
    #             model:'location'
    #         Router.go "/location/#{new_id}/edit"    
    
                
            
    # Template.locations.helpers
    #     location_docs: ->
    #         Docs.find 
    #             model:'location'
                
                
        
if Meteor.isServer
    Meteor.publish 'user_sent_location', (username)->
        Docs.find   
            model:'location'
            _author_username:username
    Meteor.publish 'product_location', (product_id)->
        Docs.find   
            model:'location'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/location/:doc_id/edit', (->
        @layout 'layout'
        @render 'location_edit'
        ), name:'location_edit'



    Template.location_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.location_edit.events
        'click .send_location': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    location = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update location._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'location sent',
                        ''
                        'success'
                    Router.go "/location/#{@_id}/"
                    )
            )

        'click .delete_location':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/location"
                            