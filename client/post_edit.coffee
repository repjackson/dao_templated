Router.route '/post/:doc_id/edit', (->
    @layout 'fullscreen'
    @render 'post_edit'
    ), name:'post_edit'
Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'target_from_post_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'all_users', ->
    @autorun => @subscribe 'tag_results',
        # Router.current().params.doc_id
        picked_tags.array()
        Session.get('searching')
        Session.get('current_query')
        Session.get('dummy')
    

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'source'

Template.post_edit.onRendered ->
    # Meteor.setTimeout ->
    #     today = new Date()
    #     $('#availability')
    #         .calendar({
    #             inline:true
    #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
    #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
    #         })
    # , 2000

Template.post_edit.helpers
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
        post = Docs.findOne Router.current().params.doc_id
        if post.target_id
            Meteor.users.findOne
                _id: post.target_id
    members: ->
        post = Docs.findOne Router.current().params.doc_id
        Meteor.users.find({
            # levels: $in: ['member','domain']
            _id: $ne: Meteor.userId()
        }, {
            sort:points:1
            limit:10
            })
    # subtotal: ->
    #     post = Docs.findOne Router.current().params.doc_id
    #     post.amount*post.target_ids.length
    
    point_max: ->
        if Meteor.user().username is 'one'
            1000
        else 
            Meteor.user().points
    
    can_submit: ->
        post = Docs.findOne Router.current().params.doc_id
        post.amount and post.target_id


Template.post_edit.events
    # 'click .complete_post': (e,t)->
    #     Session.set('posting',true)
    #     if @purchase_amount
    #         if Meteor.user().points and @purchase_amount < Meteor.user().points
    #             Meteor.call 'complete_post', @_id, =>
    #                 Router.go "/product/#{@product_id}"
    #                 Session.set('posting',false)
    #         else 
    #             alert "not enough points"
    #             Router.go "/user/#{Meteor.user().username}/points"
    #             Session.set('posting',false)
    #     else 
    #         alert 'no purchase amount'
        
        
    'click .delete_post': ->
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



    'click .cancel_post': ->
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
        Meteor.call 'send_post', @_id, =>
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

            Router.go "/post/#{@_id}"
        # )