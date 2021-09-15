if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'docs', picked_tags.array(), Router.current().params.model_slug

    Template.model_view.helpers
        current_model: ->
            Router.current().params.model_slug
        model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

            Docs.find
                model:model.slug

        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            "#{model.slug}_view"

        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Router.current().params.doc_id

    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Router.current().params.model_slug
            console.log model
            # new_id = Docs.insert
            #     model: Router.current().params.model_slug
            # Router.go "/edit/#{new_id}"


# if Meteor.isServer
#     Meteor.publish 'model', (slug)->
#         Docs.find
#             model:'model'
#             slug:slug

#     Meteor.publish 'model_fields_from_slug', (slug)->
#         model = Docs.findOne
#             model:'model'
#             slug:slug
#         Docs.find
#             model:'field'
#             parent_id:model._id

#     Meteor.publish 'model_fields_from_id', (model_id)->
#         model = Docs.findOne model_id
#         Docs.find
#             model:'field'
#             parent_id:model._id


if Meteor.isClient
    Router.route '/model/edit/:doc_id/', (->
        @layout 'model_edit_layout'
        @render 'model_edit_dashboard'
        ), name:'model_edit_dashboard'


    Template.model_edit_layout.onCreated ->
        @autorun -> Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields_from_id', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_docs', 'field_type'

    Template.field_edit.onRendered ->


    Template.field_edit.helpers
        viewing_content: ->
            Session.equals('expand_field', @_id)

    Template.field_edit.events
        'click .field_edit': (e,t)->
            $('.segment').removeClass('raised')

            $(e.currentTarget).closest('.segment').toggleClass('raised')

            if Session.equals('expand_field', @_id)
                Session.set('expand_field', null)
            else
                Session.set('expand_field', @_id)




    Template.model_edit_layout.helpers
        fields: ->
            Docs.find {
                model:'field'
                parent_id: Router.current().params.doc_id
            }, sort:rank:1

    Template.model_edit_layout.events
        # 'click #delete_model': (e,t)->
        #     if confirm 'delete model?'
        #         Docs.remove Router.current().params.doc_id, ->
        #             Router.go "/"

        'click .add_field': ->
            Docs.insert
                model:'field'
                _timestamp:Date.now()
                _author_id:Meteor.userId()
                parent_id: Router.current().params.doc_id
                view_roles: ['dev', 'admin', 'user', 'public']
                edit_roles: ['dev', 'admin', 'user']

    Template.field_edit.helpers
        is_ref: ->
            ref_field_types =
                Docs.find(
                    model:'field_type'
                    slug: $in: ['single_doc', 'multi_doc','children']
                ).fetch()
            ids = _.pluck(ref_field_types, '_id')
            # console.log ids
            @field_type_id in ids

        is_user_ref: ->
            @field_type in ['single_user', 'multi_user']



    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Router.go "/m/model"
