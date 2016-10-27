require 'faraday_middleware/aws_signers_v4'
require 'elasticsearch'


class MapsController < ApplicationController
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  # GET /maps
  # GET /maps.json
  def index
    @a=params[:search]
    client          = Elasticsearch::Client.new(url: 'PUT-AWS-ELASTIC-SEARCH-URL') do |f|
                      f.request :aws_signers_v4,
                        credentials: Aws::Credentials.new( 'PASTE-YOUR-AWS-ACCESS-TOKEN', 'PASTE-YOUR-AWS-ACCESS-KEY' ),
                        service_name: 'es',
                        region: 'us-west-2'
                      end
    elasticsearch   = client.search({from: 0, size: 10000, index: 'twittmaps', q: @a })["hits"]["hits"]
    result          = []
    elasticsearch.each do |es|
      result.push({"latitude" => es["_source"]["latitude"], "longitude" => es["_source"]["longitude"]})
    end
    @maps = result
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
  end

  # GET /maps/new
  def new
    @map = Map.new
  end

  # GET /maps/1/edit
  def edit
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(map_params)

    respond_to do |format|
      if @map.save
        format.html { redirect_to @map, notice: 'Map was successfully created.' }
        format.json { render :show, status: :created, location: @map }
      else
        format.html { render :new }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maps/1
  # PATCH/PUT /maps/1.json
  def update
    respond_to do |format|
      if @map.update(map_params)
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { render :show, status: :ok, location: @map }
      else
        format.html { render :edit }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map.destroy
    respond_to do |format|
      format.html { redirect_to maps_url, notice: 'Map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.require(:map).permit(:latitude, :longitude, :address, :description, :title)
    end
end
