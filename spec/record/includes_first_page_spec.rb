# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:datastore) { 'http://depay.fi/v2' }
  before { DHC.config.placeholder('datastore', datastore) }

  let(:stub_campaign_request) do
    stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
      .to_return(body: {
        'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d",
        'entry' => { 'href' => "#{datastore}/local-entries/lakj35asdflkj1203va" },
        'user' => { 'href' => "#{datastore}/users/lakj35asdflkj1203va" }
      }.to_json)
  end

  let(:stub_entry_request) do
    stub_request(:get, "#{datastore}/local-entries/lakj35asdflkj1203va")
      .to_return(body: { 'name' => 'Casa Ferlin' }.to_json)
  end

  let(:stub_user_request) do
    stub_request(:get, "#{datastore}/users/lakj35asdflkj1203va")
      .to_return(body: { 'name' => 'Mario' }.to_json)
  end

  context 'singlelevel includes' do
    before do
      class LocalEntry < DHS::Record
        endpoint '{+datastore}/local-entries'
        endpoint '{+datastore}/local-entries/{id}'
      end

      class User < DHS::Record
        endpoint '{+datastore}/users'
        endpoint '{+datastore}/users/{id}'
      end

      class Favorite < DHS::Record
        endpoint '{+datastore}/favorites'
        endpoint '{+datastore}/favorites/{id}'
      end
      stub_request(:get, "#{datastore}/local-entries/1")
        .to_return(body: { company_name: 'depay.fi' }.to_json)
      stub_request(:get, "#{datastore}/users/1")
        .to_return(body: { name: 'Mario' }.to_json)
      stub_request(:get, "#{datastore}/favorites/1")
        .to_return(body: {
          local_entry: { href: "#{datastore}/local-entries/1" },
          user: { href: "#{datastore}/users/1" }
        }.to_json)
    end

    it 'includes a resource' do
      favorite = Favorite.includes_first_page(:local_entry).find(1)
      expect(favorite.local_entry.company_name).to eq 'depay.fi'
    end

    it 'duplicates a class' do
      expect(Favorite.object_id).not_to eq(Favorite.includes_first_page(:local_entry).object_id)
    end

    it 'includes a list of resources' do
      favorite = Favorite.includes_first_page(:local_entry, :user).find(1)
      expect(favorite.local_entry).to be_kind_of LocalEntry
      expect(favorite.local_entry.company_name).to eq 'depay.fi'
      expect(favorite.user.name).to eq 'Mario'
    end

    it 'includes an array of resources' do
      favorite = Favorite.includes_first_page(%i[local_entry user]).find(1)
      expect(favorite.local_entry.company_name).to eq 'depay.fi'
      expect(favorite.user.name).to eq 'Mario'
    end
  end

  context 'multilevel includes' do
    before do
      class Feedback < DHS::Record
        endpoint '{+datastore}/feedbacks'
        endpoint '{+datastore}/feedbacks/{id}'
      end
      stub_campaign_request
      stub_entry_request
      stub_user_request
    end

    it 'includes linked resources while fetching multiple resources from one service' do
      stub_request(:get, "#{datastore}/feedbacks?has_reviews=true")
        .to_return(status: 200, body: {
          items: [
            {
              'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
              'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
            }
          ]
        }.to_json)

      feedbacks = Feedback.includes_first_page(campaign: :entry).where(has_reviews: true)
      expect(feedbacks.first.campaign.entry.name).to eq 'Casa Ferlin'
    end

    it 'includes linked resources while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      feedbacks = Feedback.includes_first_page(campaign: :entry).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
    end

    it 'includes linked resources with array while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      feedbacks = Feedback.includes_first_page(campaign: %i[entry user]).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
      expect(feedbacks.campaign.user.name).to eq 'Mario'
    end

    it 'includes list of linked resources while fetching a single resource from one service' do
      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" },
          'user' => { 'href' => "#{datastore}/users/lakj35asdflkj1203va" }
        }.to_json)

      feedbacks = Feedback.includes_first_page(:user, campaign: %i[entry user]).find(123)
      expect(feedbacks.campaign.entry.name).to eq 'Casa Ferlin'
      expect(feedbacks.campaign.user.name).to eq 'Mario'
      expect(feedbacks.user.name).to eq 'Mario'
    end

    context 'include objects from known services' do
      let(:stub_feedback_request) do
        stub_request(:get, "#{datastore}/feedbacks")
          .to_return(status: 200, body: {
            items: [
              {
                'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
                'entry' => {
                  'href' => "#{datastore}/local-entries/lakj35asdflkj1203va"
                }
              }
            ]
          }.to_json)
      end

      let(:interceptor) { spy('interceptor') }

      before do
        class Entry < DHS::Record
          endpoint '{+datastore}/local-entries/{id}'
        end
        DHC.config.interceptors = [interceptor]
      end

      it 'uses interceptors for included links from known services' do
        stub_feedback_request
        stub_entry_request
        expect(Feedback.includes_first_page(:entry).where.first.entry.name).to eq 'Casa Ferlin'
        expect(interceptor).to have_received(:before_request).twice
      end
    end

    context 'includes not present in response' do
      before do
        class Parent < DHS::Record
          endpoint '{+datastore}/local-parents'
          endpoint '{+datastore}/local-parents/{id}'
        end

        class OptionalChild < DHS::Record
          endpoint '{+datastore}/DePayFiildren/{id}'
        end
      end

      it 'handles missing but included fields in single object response' do
        stub_request(:get, "#{datastore}/local-parents/1")
          .to_return(status: 200, body: {
            'href' => "#{datastore}/local-parents/1",
            'name' => 'RspecName'
          }.to_json)

        parent = Parent.includes_first_page(:optional_children).find(1)
        expect(parent).not_to be nil
        expect(parent.name).to eq 'RspecName'
        expect(parent.optional_children).to be nil
      end

      it 'handles missing but included fields in collection response' do
        stub_request(:get, "#{datastore}/local-parents")
          .to_return(status: 200, body: {
            items: [
              {
                'href' => "#{datastore}/local-parents/1",
                'name' => 'RspecParent'
              }, {
                'href' => "#{datastore}/local-parents/2",
                'name' => 'RspecParent2',
                'optional_child' => {
                  'href' => "#{datastore}/DePayFiildren/1"
                }
              }
            ]
          }.to_json)

        stub_request(:get, "#{datastore}/DePayFiildren/1")
          .to_return(status: 200, body: {
            href: "#{datastore}/local_children/1",
            name: 'RspecOptionalChild1'
          }.to_json)

        child = Parent.includes_first_page(:optional_child).where[1].optional_child
        expect(child).not_to be nil
        expect(child.name).to eq 'RspecOptionalChild1'
      end
    end
  end

  context 'links pointing to nowhere' do
    before do
      class Feedback < DHS::Record
        endpoint '{+datastore}/feedbacks'
        endpoint '{+datastore}/feedbacks/{id}'
      end

      stub_request(:get, "#{datastore}/feedbacks/123")
        .to_return(status: 200, body: {
          'href' => "#{datastore}/feedbacks/-Sc4_pYNpqfsudzhtivfkA",
          'campaign' => { 'href' => "#{datastore}/content-ads/51dfc5690cf271c375c5a12d" }
        }.to_json)

      stub_request(:get, "#{datastore}/content-ads/51dfc5690cf271c375c5a12d")
        .to_return(status: 404)
    end

    it 'raises DHC::NotFound for links that cannot be included' do
      expect(-> {
        Feedback.includes_first_page(campaign: :entry).find(123)
      }).to raise_error DHC::NotFound
    end

    it 'ignores DHC::NotFound for links that cannot be included if configured so with reference options' do
      feedback = Feedback
        .includes_first_page(campaign: :entry)
        .references(campaign: { ignore: [DHC::NotFound] })
        .find(123)
      expect(feedback.campaign._raw.keys.length).to eq 1
    end
  end

  context 'modules' do
    before do
      module Services
        class LocalEntry < DHS::Record
          endpoint '{+datastore}/local-entries'
        end

        class Feedback < DHS::Record
          endpoint '{+datastore}/feedbacks'
        end
      end
      stub_request(:get, 'http://depay.fi/v2/feedbacks?id=123')
        .to_return(body: [].to_json)
    end

    it 'works with modules' do
      Services::Feedback.includes_first_page(campaign: :entry).find(123)
    end
  end

  context 'arrays' do
    before do
      class Place < DHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end
    end

    let!(:place_request) do
      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'relations' => [
            { 'href' => "#{datastore}/place/relations/2" },
            { 'href' => "#{datastore}/place/relations/3" }
          ]
        }.to_json)
    end

    let!(:relation_request_1) do
      stub_request(:get, "#{datastore}/place/relations/2")
        .to_return(body: { name: 'Category' }.to_json)
    end

    let!(:relation_request_2) do
      stub_request(:get, "#{datastore}/place/relations/3")
        .to_return(body: { name: 'ZeFrank' }.to_json)
    end

    it 'includes items of arrays' do
      place = Place.includes_first_page(:relations).find(1)
      expect(place.relations.first.name).to eq 'Category'
      expect(place.relations[1].name).to eq 'ZeFrank'
    end

    context 'parallel with empty links' do
      let!(:place_request_2) do
        stub_request(:get, "#{datastore}/place/2")
          .to_return(body: {
            'relations' => []
          }.to_json)
      end

      it 'loads places in parallel and merges included data properly' do
        place = Place.includes_first_page(:relations).find(2, 1)
        expect(place[0].relations.empty?).to be true
        expect(place[1].relations[0].name).to eq 'Category'
        expect(place[1].relations[1].name).to eq 'ZeFrank'
      end
    end
  end

  context 'empty collections' do
    it 'skips including empty collections' do
      class Place < DHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end

      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'available_products' => {
            'url' => "#{datastore}/place/1/products",
            'items' => []
          }
        }.to_json)

      place = Place.includes_first_page(:available_products).find(1)
      expect(place.available_products.empty?).to eq true
    end
  end

  context 'extend items with arrays' do
    it 'extends base items with arrays' do
      class Place < DHS::Record
        endpoint '{+datastore}/place'
        endpoint '{+datastore}/place/{id}'
      end

      stub_request(:get, "#{datastore}/place/1")
        .to_return(body: {
          'contracts' => {
            'items' => [{ 'href' => "#{datastore}/place/1/contacts/1" }]
          }
        }.to_json)

      stub_request(:get, "#{datastore}/place/1/contacts/1")
        .to_return(body: {
          'products' => { 'href' => "#{datastore}/place/1/contacts/1/products" }
        }.to_json)

      place = Place.includes_first_page(:contracts).find(1)
      expect(place.contracts.first.products.href).to eq "#{datastore}/place/1/contacts/1/products"
    end
  end

  context 'unexpanded response when requesting the included collection' do
    before do
      class Customer < DHS::Record
        endpoint '{+datastore}/customer/{id}'
      end
    end

    let!(:customer_request) do
      stub_request(:get, "#{datastore}/customer/1")
        .to_return(body: {
          places: {
            href: "#{datastore}/places"
          }
        }.to_json)
    end

    let!(:places_request) do
      stub_request(:get, "#{datastore}/places")
        .to_return(body: {
          items: [{ href: "#{datastore}/places/1" }]
        }.to_json)
    end

    let!(:place_request) do
      stub_request(:get, "#{datastore}/places/1")
        .to_return(body: {
          name: 'Casa Ferlin'
        }.to_json)
    end

    it 'loads the collection and the single items, if not already expanded' do
      place = Customer.includes_first_page(:places).find(1).places.first
      assert_requested(place_request)
      expect(place.name).to eq 'Casa Ferlin'
    end

    context 'forwarding options' do
      let!(:places_request) do
        stub_request(:get, "#{datastore}/places")
          .with(headers: { 'Authorization' => 'Bearer 123' })
          .to_return(
            body: {
              items: [{ href: "#{datastore}/places/1" }]
            }.to_json
          )
      end

      let!(:place_request) do
        stub_request(:get, "#{datastore}/places/1")
          .with(headers: { 'Authorization' => 'Bearer 123' })
          .to_return(
            body: {
              name: 'Casa Ferlin'
            }.to_json
          )
      end

      it 'forwards options used to expand those unexpanded items' do
        place = Customer
          .includes_first_page(:places)
          .references(places: { headers: { 'Authorization' => 'Bearer 123' } })
          .find(1)
          .places.first
        assert_requested(place_request)
        expect(place.name).to eq 'Casa Ferlin'
      end
    end
  end

  context 'includes with options' do
    before do
      class Customer < DHS::Record
        endpoint '{+datastore}/customers/{id}'
        endpoint '{+datastore}/customers'
      end

      class Place < DHS::Record
        endpoint '{+datastore}/places'
      end

      stub_request(:get, "#{datastore}/places?forwarded_params=123")
        .to_return(body: {
          'items' => [{ id: 1 }]
        }.to_json)
    end

    it 'forwards includes options to requests made for those includes' do
      stub_request(:get, "#{datastore}/customers/1")
        .to_return(body: {
          'places' => {
            'href' => "#{datastore}/places"
          }
        }.to_json)
      customer = Customer
        .includes_first_page(:places)
        .references(places: { params: { forwarded_params: 123 } })
        .find(1)
      expect(customer.places.first.id).to eq 1
    end

    it 'is chain-able' do
      stub_request(:get, "#{datastore}/customers?name=Steve")
        .to_return(body: [
          'places' => {
            'href' => "#{datastore}/places"
          }
        ].to_json)
      customers = Customer
        .where(name: 'Steve')
        .references(places: { params: { forwarded_params: 123 } })
        .includes_first_page(:places)
      expect(customers.first.places.first.id).to eq 1
    end
  end

  context 'more complex examples' do
    before do
      class Place < DHS::Record
        endpoint 'http://datastore/places/{id}'
      end
    end

    it 'forwards complex references' do
      stub_request(:get, 'http://datastore/places/123?limit=1&forwarded_params=for_place')
        .to_return(body: {
          'contracts' => {
            'href' => 'http://datastore/places/123/contracts'
          }
        }.to_json)
      stub_request(:get, 'http://datastore/places/123/contracts?forwarded_params=for_contracts')
        .to_return(body: {
          href: 'http://datastore/places/123/contracts?forwarded_params=for_contracts',
          items: [
            { product: { 'href' => 'http://datastore/products/llo' } }
          ]
        }.to_json)
      stub_request(:get, 'http://datastore/products/llo?forwarded_params=for_product')
        .to_return(body: {
          'href' => 'http://datastore/products/llo',
          'name' => 'Local Logo'
        }.to_json)
      place = Place
        .options(params: { forwarded_params: 'for_place' })
        .includes_first_page(contracts: :product)
        .references(
          contracts: {
            params: { forwarded_params: 'for_contracts' },
            product: { params: { forwarded_params: 'for_product' } }
          }
        )
        .find_by(id: '123')
      expect(
        place.contracts.first.product.name
      ).to eq 'Local Logo'
    end

    it 'expands empty arrays' do
      stub_request(:get, 'http://datastore/places/123')
        .to_return(body: {
          'contracts' => {
            'href' => 'http://datastore/places/123/contracts'
          }
        }.to_json)
      stub_request(:get, 'http://datastore/places/123/contracts')
        .to_return(body: {
          href: 'http://datastore/places/123/contracts',
          items: []
        }.to_json)
      place = Place.includes_first_page(:contracts).find('123')
      expect(place.contracts.collection?).to eq true
      expect(
        place.contracts.as_json
      ).to eq('href' => 'http://datastore/places/123/contracts', 'items' => [])
      expect(place.contracts.to_a).to eq([])
    end
  end

  context 'include and merge arrays when calling find in parallel' do
    before do
      class Place < DHS::Record
        endpoint 'http://datastore/places/{id}'
      end
      stub_request(:get, 'http://datastore/places/1')
        .to_return(body: {
          category_relations: [{ href: 'http://datastore/category/1' }, { href: 'http://datastore/category/2' }]
        }.to_json)
      stub_request(:get, 'http://datastore/places/2')
        .to_return(body: {
          category_relations: [{ href: 'http://datastore/category/2' }, { href: 'http://datastore/category/1' }]
        }.to_json)
      stub_request(:get, 'http://datastore/category/1').to_return(body: { name: 'Food' }.to_json)
      stub_request(:get, 'http://datastore/category/2').to_return(body: { name: 'Drinks' }.to_json)
    end

    it 'includes and merges linked resources in case of an array of links' do
      places = Place
        .includes_first_page(:category_relations)
        .find(1, 2)
      expect(places[0].category_relations[0].name).to eq 'Food'
      expect(places[1].category_relations[0].name).to eq 'Drinks'
    end
  end

  context 'single href with array response' do
    it 'extends base items with arrays' do
      class Sector < DHS::Record
        endpoint '{+datastore}/sectors'
        endpoint '{+datastore}/sectors/{id}'
      end

      stub_request(:get, "#{datastore}/sectors")
        .with(query: hash_including(key: 'my_service'))
        .to_return(body: [
          {
            href: "#{datastore}/sectors/1",
            services: {
              href: "#{datastore}/sectors/1/services"
            },
            keys: [
              {
                key: 'my_service',
                language: 'de'
              }
            ]
          }
        ].to_json)

      stub_request(:get, "#{datastore}/sectors/1/services")
        .to_return(body: [
          {
            href: "#{datastore}/services/s1",
            price_in_cents: 9900,
            key: 'my_service_service_1'
          },
          {
            href: "#{datastore}/services/s2",
            price_in_cents: 19900,
            key: 'my_service_service_2'
          }
        ].to_json)

      sector = Sector.includes_first_page(:services).find_by(key: 'my_service')
      expect(sector.services.length).to eq 2
      expect(sector.services.first.key).to eq 'my_service_service_1'
    end
  end

  context 'include for POST/create' do
    before do
      class Record < DHS::Record
        endpoint 'https://records'
      end
      stub_request(:post, 'https://records/')
        .with(body: { color: 'blue' }.to_json)
        .to_return(
          body: {
            color: 'blue',
            alternative_categories: [
              { href: 'https://categories/blue' }
            ]
          }.to_json
        )
      stub_request(:get, 'https://categories/blue')
        .to_return(
          body: {
            name: 'blue'
          }.to_json
        )
    end

    it 'includes the resources from the post response' do
      records = Record.includes_first_page(:alternative_categories).create(color: 'blue')
      expect(records.alternative_categories.first.name).to eq 'blue'
    end
  end

  context 'nested within another structure' do
    before do
      class Place < DHS::Record
        endpoint 'https://places/{id}'
      end
      stub_request(:get, 'https://places/1')
        .to_return(body: {
          customer: {
            salesforce: {
              href: 'https://salesforce/customers/1'
            }
          }
        }.to_json)
    end

    let!(:nested_request) do
      stub_request(:get, 'https://salesforce/customers/1')
        .to_return(body: {
          name: 'Steve'
        }.to_json)
    end

    it 'includes data that has been nested in an additional structure' do
      place = Place.includes_first_page(customer: :salesforce).find(1)
      expect(nested_request).to have_been_requested
      expect(place.customer.salesforce.name).to eq 'Steve'
    end

    context 'included data has a configured record endpoint option' do
      before do
        class SalesforceCustomer < DHS::Record
          endpoint 'https://salesforce/customers/{id}', headers: { 'Authorization': 'Bearer 123' }
        end
      end

      let!(:nested_request) do
        stub_request(:get, 'https://salesforce/customers/1')
          .with(headers: { 'Authorization' => 'Bearer 123' })
          .to_return(body: {
            name: 'Steve'
          }.to_json)
      end

      it 'includes data that has been nested in an additional structure' do
        place = Place.includes_first_page(customer: :salesforce).find(1)
        expect(nested_request).to have_been_requested
        expect(place.customer.salesforce.name).to eq 'Steve'
      end
    end
  end

  context 'include empty structures' do
    before do
      class Place < DHS::Record
        endpoint 'https://places/{id}'
      end
      stub_request(:get, 'https://places/1')
        .to_return(body: {
          id: '123'
        }.to_json)
    end

    it 'skips includes when there is nothing and also does not raise an exception' do
      expect(-> {
        Place.includes_first_page(contracts: :product).find(1)
      }).not_to raise_exception
    end
  end

  context 'include partially empty structures' do
    before do
      class Place < DHS::Record
        endpoint 'https://places/{id}'
      end
      stub_request(:get, 'https://places/1')
        .to_return(body: {
          id: '123',
          customer: {}
        }.to_json)
    end

    it 'skips includes when there is nothing and also does not raise an exception' do
      expect(-> {
        Place.includes_first_page(customer: :salesforce).find(1)
      }).not_to raise_exception
    end
  end
end
