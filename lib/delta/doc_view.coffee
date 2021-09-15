if Meteor.isClient
    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        # console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'upvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'downvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_docs', 'field_type'

    Template.model_doc_view.helpers
        # current_model: ->

            # Router.current().params.model_slug
        template_exists: ->
            false
            # current_model = Router.current().params.model_slug
            # # console.log "#{current_model}_view"
            # if Template["#{current_model}_view"]
            #     # console.log 'true'
            #     return true
            # else
            #     # console.log 'false'
            #     return false
        model_template: ->
            current_model = Router.current().params.model_slug
            # console.log "#{current_model}_view"
            "#{current_model}_view"



    Template.model_doc_view.events
        'click .back_to_model': (e,t)->
            Session.set 'loading', true
            current_model = Router.current().params.model_slug
            Meteor.call 'set_facets', current_model, ->
                Session.set 'loading', false
            $(e.currentTarget).closest('.grid').transition('fade left', 250)
            Meteor.setTimeout ->
                Router.go "/m/#{current_model}"
            , 100
            
            
            
            
if Meteor.isClient
    Router.route '/m/:model_slug/:doc_id', (->
        @render 'model_doc_view'
        ), name:'doc_view'
    Router.route '/m/:model_slug/:doc_id/view', (->
        @render 'model_doc_view'
        ), name:'doc_view_long'

    Router.route '/m/:model_slug/:doc_id/edit', (->
        @render 'model_doc_edit'
        ), name:'doc_edit'


    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_docs', 'field_type'

    Template.model_doc_edit.helpers
        template_exists: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            unless current_model.model is 'model'
                if Template["#{current_model}_edit"]
                    return true
                else
                    return false
            else
                return false
            # false
            # false
            # # current_model = Docs.findOne(slug:Router.current().params.model_slug).model
            # current_model = Router.current().params.model_slug
            # if Template["#{current_model}_doc_edit"]
            #     # console.log 'true'
            #     return true
            # else
            #     # console.log 'false'
            #     return false

        model_template: ->
            # current_model = Docs.findOne(slug:Router.current().params.model_slug).model
            current_model = Router.current().params.model_slug
            "#{current_model}_edit"


    Template.model_doc_edit.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Router.go "/m/#{@model}"            