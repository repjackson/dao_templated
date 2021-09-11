Router.route '/transfers', (->
    @render 'transfers'
    ), name:'transfers'

@picked_tags = new ReactiveArray []
@picked_authors = new ReactiveArray []
@picked_targets = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Template.leaderboard.onCreated ->
    @autorun -> Meteor.subscribe 'today_leaderboard', -> 


Template.tag_picker.onCreated ->
    @autorun => @subscribe 'ref_doc', @data, ->
Template.unpick_tag.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.flat_tag_picker.onCreated ->
    @autorun => @subscribe 'flat_ref_doc', @data, ->
Template.tag_picker.events
    'click .pick_tag': -> 
        picked_tags.push @title
        Session.set('viewing_post_id',null)
# Template.profile_picker.events
#     'click .pick_tag': -> 
#         picked_tags.push @title
#         Session.set('viewing_post_id',null)
#         # Meteor.call 'call_wiki', @title,=>
#         #     console.log 'called wiki on', @title

Template.flat_tag_picker.helpers
    ref_doc_flat: ->
        # console.log @valueOf()
        found = Docs.findOne 
            model:'transfer'
            title:@valueOf()
        if found 
            found
        else 
            Docs.findOne
                model:'transfer'
                tags:$in:[@valueOf()]

Template.tag_picker.helpers
    ref_doc: ->
        # console.log @valueOf()
        Docs.findOne({
            model:'transfer'
            tags:$in:[@title]
        }, {sort:points:-1})

Template.profile_picker.helpers
    ref_doc: ->
        # console.log @valueOf()
        Docs.findOne({
            model:'transfer'
            tags:$in:[@title]
        }, {sort:points:-1})




Template.transfers.onCreated ->
    Session.setDefault('transfer_filter','all')
    # @autorun -> Meteor.subscribe 'all_users', -> 
    @autorun -> Meteor.subscribe 'transfer_tags', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        , ->
    
    @autorun => Meteor.subscribe 'transfers', 
        null
        'sent'
        picked_tags.array()
        picked_authors.array()
        picked_targets.array()
        picked_timestamp_tags.array()
        picked_location_tags.array()
        Session.get('transfer_filter')
        Session.get('transfer_sort_key')
        Session.get('transfer_sort_direction')
        ,->

Template.transfers.helpers
    tag_results: -> Results.find(model:'tag')
    location_tag_results: -> Results.find(model:'location_tag')
    target_results: -> Results.find(model:'target_tag')
    author_results: -> Results.find(model:'author_tag')
    picked_tags: -> picked_tags.array()
    picked_authors: -> picked_authors.array()
    picked_targets: -> picked_targets.array()
    picked_location_tags: -> picked_location_tags.array()
    transfer_docs: ->
        match = {model:'transfer'}
        if picked_tags.array().length > 0
            match.tags = $all: picked_tags.array()
        Docs.find match,
            sort: _timestamp:-1
Template.leaderboard.helpers
    most_sent_today: ->
        Meteor.users.find({total_sent_day: $gt:0},
            sort:
                total_sent_day:-1
        )
    most_received_today: ->
        Meteor.users.find({total_received_day: $gt:0},
            sort:
                total_received_day:-1
        )



Template.transfer_item.events
    'click .fly_right': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 250)

Template.transfers.events
    # 'click .pick_tag': -> picked_tags.push @title
    'click .unpick_tag': -> picked_tags.remove @valueOf()
    'click #clear_tags': -> picked_tags.clear()
    
    'click .pick_location_tag': -> picked_location_tags.push @title
    'click .unpick_location_tag': -> picked_location_tags.remove @valueOf()
    
    'click .pick_target_tag': -> picked_targets.push @title
    'click .unpick_target_tag': -> picked_targets.remove @valueOf()
   
    'click .pick_author_tag': -> picked_authors.push @title
    'click .unpick_author_tag': -> picked_authors.remove @valueOf()
    # 'click #clear_tags': -> picked_tags.clear()


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
  
  Router.route '/transfer/:doc_id/edit', (->
    @layout 'fullscreen'
    @render 'edit_transfer'
    ), name:'edit_transfer'
Template.transfer_edit.onCreated ->
    @autorun => Meteor.subscribe 'target_from_transfer_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'all_users', ->
    @autorun => @subscribe 'tag_results',
        # Router.current().params.doc_id
        picked_tags.array()
        Session.get('searching')
        Session.get('current_query')
        Session.get('dummy')
    

Template.transfer_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'source'

Template.transfer_edit.onRendered ->
    # Meteor.setTimeout ->
    #     today = new Date()
    #     $('#availability')
    #         .calendar({
    #             inline:true
    #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
    #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
    #         })
    # , 2000

Template.transfer_edit.helpers
    balance_after_purchase: ->
        Meteor.user().points - @purchase_amount
    percent_difference: ->
        balance_after_purchase = 
            Meteor.user().points - @purchase_amount
        # difference
        @purchase_amount/Meteor.user().points

    # terms: ->
    #     Terms.find()
    # suggestions: ->
    #     Tags.find()
    target: ->
        transfer = Docs.findOne Router.current().params.doc_id
        if transfer.target_id
            Meteor.users.findOne
                _id: transfer.target_id
    members: ->
        transfer = Docs.findOne Router.current().params.doc_id
        Meteor.users.find({
            # levels: $in: ['member','domain']
            _id: $ne: Meteor.userId()
        }, {
            sort:points:1
            limit:10
            })
    # subtotal: ->
    #     transfer = Docs.findOne Router.current().params.doc_id
    #     transfer.amount*transfer.target_ids.length
    
    point_max: ->
        if Meteor.user().username is 'one'
            1000
        else 
            Meteor.user().points
    
    can_submit: ->
        transfer = Docs.findOne Router.current().params.doc_id
        transfer.amount and transfer.target_id


Template.transfer_edit.events
    # 'click .complete_transfer': (e,t)->
    #     Session.set('transfering',true)
    #     if @purchase_amount
    #         if Meteor.user().points and @purchase_amount < Meteor.user().points
    #             Meteor.call 'complete_transfer', @_id, =>
    #                 Router.go "/product/#{@product_id}"
    #                 Session.set('transfering',false)
    #         else 
    #             alert "not enough points"
    #             Router.go "/user/#{Meteor.user().username}/points"
    #             Session.set('transfering',false)
    #     else 
    #         alert 'no purchase amount'
        
        
    'click .delete_transfer': ->
        Docs.remove @_id
        Router.go "/"


    'click .parse_quick_add': ->
        split = @quick_add.split(' ')
        if split[0] is 'send'
            Docs.update Router.current().params.doc_id, 
                $set:
                    amount:parseInt(split[1])

    'click .add_target': ->
        Docs.update Router.current().params.doc_id,
            $set:
                target_id:@_id
    'click .remove_target': ->
        Docs.update Router.current().params.doc_id,
            $unset:
                target_id:1
    'keyup .new_tag': _.throttle((e,t)->
        query = $('.new_tag').val()
        if query.length > 0
            Session.set('searching', true)
        else
            Session.set('searching', false)
        Session.set('current_query', query)
        
        if e.which is 13
            element_val = t.$('.new_tag').val().toLowerCase().trim()
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:element_val
            picked_tags.push element_val
            Meteor.call 'log_term', element_val, ->
            Session.set('searching', false)
            Session.set('current_query', '')
            Session.set('dummy', !Session.get('dummy'))
            t.$('.new_tag').val('')
    , 1000)

    'click .remove_element': (e,t)->
        element = @valueOf()
        field = Template.currentData()
        picked_tags.remove element
        Docs.update Router.current().params.doc_id,
            $pull:tags:element
        t.$('.new_tag').focus()
        t.$('.new_tag').val(element)
        Session.set('dummy', !Session.get('dummy'))


    # 'click .select_term': (e,t)->
    #     # picked_tags.push @title
    #     Docs.update Router.current().params.doc_id,
    #         $addToSet:tags:@title
    #     picked_tags.push @title
    #     $('.new_tag').val('')
    #     Session.set('current_query', '')
    #     Session.set('searching', false)
    #     Session.set('dummy', !Session.get('dummy'))


    'blur .edit_description': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        Docs.update Router.current().params.doc_id,
            $set:description:textarea_val


    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        Docs.update Router.current().params.doc_id,
            $set:"#{@key}":val


    'blur .point_amount': (e,t)->
        val = parseInt t.$('.point_amount').val()
        Docs.update Router.current().params.doc_id,
            $set:amount:val



    'click .cancel_transfer': ->
        # Swal.fire({
        #     title: "confirm cancel?"
        #     text: ""
        #     icon: 'question'
        #     showCancelButton: true,
        #     confirmButtonColor: 'red'
        #     confirmButtonText: 'confirm'
        #     cancelButtonText: 'cancel'
        #     reverseButtons: true
        # }).then((result)=>
        # if result.value
        Docs.remove @_id
        Router.go '/'
        # )
        
    'click .submit': (e,t)->
        # Swal.fire({
        #     title: "confirm send #{@amount}pts?"
        #     text: ""
        #     icon: 'question'
        #     showCancelButton: true,
        #     confirmButtonColor: 'green'
        #     confirmButtonText: 'confirm'
        #     cancelButtonText: 'cancel'
        #     reverseButtons: true
        # }).then((result)=>
        #     if result.value
        Meteor.call 'send_transfer', @_id, =>
            $(e.currentTarget).closest('.grid').transition('fly right',500)
            # Swal.fire(
            #     title:"#{@amount} sent"
            #     icon:'success'
            #     showConfirmButton: false
            #     position: 'top-end',
            #     timer: 1000
            # )
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@amount} sent to #{@target_username}"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )

            Router.go "/transfer/#{@_id}"
        # )





Template.single_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.single_user_edit.helpers
    user_results: -> Template.instance().user_results.get()
Template.single_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup .single_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('.single_user_select_input').val().trim()
        if search_value.length > 1
            Meteor.call 'lookup_user', search_value, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Router.current().params.doc_id
        field = Template.currentData()



        val = t.$('.edit_text').val()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:
                    target_id:@_id
                    target_image_id:@image_id
                    target_username:@username
            
        t.user_results.set null
        $('.single_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        if confirm "remove #{@username}?"
            parent = Template.parentData(1)
            field = Template.currentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{field.key}":1

        #     page_doc = Docs.findOne Router.current().params.doc_id
            # Meteor.call 'unassign_user', page_doc._id, @
