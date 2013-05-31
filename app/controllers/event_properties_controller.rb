class EventPropertiesController < ApplicationController
  # GET /events_properties
  # GET /events_properties.json
  def index
    @events_properties = EventProperty.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events_properties }
    end
  end

  # GET /events_properties/1
  # GET /events_properties/1.json
  def show
    @events_property = EventProperty.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @events_property }
    end
  end

  # GET /events_properties/new
  # GET /events_properties/new.json
  def new
    @events_property = EventProperty.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @events_property }
    end
  end

  # GET /events_properties/1/edit
  def edit
    @events_property = EventProperty.find(params[:id])
  end

  # POST /events_properties
  # POST /events_properties.json
  def create
    @events_property = EventProperty.new(params[:events_property])

    respond_to do |format|
      if @events_property.save
        format.html { redirect_to @events_property, notice: 'Events property was successfully created.' }
        format.json { render json: @events_property, status: :created, location: @events_property }
      else
        format.html { render action: "new" }
        format.json { render json: @events_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events_properties/1
  # PUT /events_properties/1.json
  def update
    @events_property = EventProperty.find(params[:id])

    respond_to do |format|
      if @events_property.update_attributes(params[:events_property])
        format.html { redirect_to @events_property, notice: 'Events property was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @events_property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events_properties/1
  # DELETE /events_properties/1.json
  def destroy
    @events_property = EventProperty.find(params[:id])
    @events_property.destroy

    respond_to do |format|
      format.html { redirect_to events_properties_url }
      format.json { head :no_content }
    end
  end
end
