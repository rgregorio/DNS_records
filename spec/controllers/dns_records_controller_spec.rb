require 'rails_helper'

RSpec.describe Api::V1::DnsRecordsController, type: :controller do
  let(:parsed_body) { JSON.parse(response.body, symbolize_names: true) }

  describe '#index' do
    context 'with the required page param' do
      let(:page) { 1 }

      let(:ip1) { '1.1.1.1' }
      let(:ip2) { '2.2.2.2' }
      let(:hostname1) { 'lorem.com' }
      let(:hostname2) { 'ipsum.com' }

      let(:payload1) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: hostname1
              }
            ]
          }
        }.to_json
      end

      let(:payload2) do
        {
          dns_records: {
            ip: ip2,
            hostnames_attributes: [
              {
                hostname: hostname2
              }
            ]
          }
        }.to_json
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload1, format: :json)
        post(:create, body: payload2, format: :json)
      end

      context 'without included and excluded optional params' do
        let(:expected_response) do
          {
            total_records: 2,
            records: [
              {
                id: 3,
                ip_address: ip1
              },
              {
                id: 4,
                ip_address: ip2
              }
            ],
            related_hostnames: [
              {
                hostname: hostname1,
                count: 1
              },
              {
                hostname: hostname2,
                count: 1
              }
            ],
            error: nil
          }
        end

        before :each do
          get(:index, params: { page: page })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns all dns records with all hostnames' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the included optional param' do
        let(:included) { hostname1 }

        let(:expected_response) do
          {
            total_records: 1,
            records: [
              {
                id: 7,
                ip_address: ip1
              }
            ],
            related_hostnames: [
              {
                :count=>1, 
                :hostname=> hostname1
              }
            ],
            error: nil
          }
        end

        before :each do
          get(:index, params: { page: page, included: included })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the included dns records without a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with the excluded optional param' do
        let(:excluded) { hostname1 }

        let(:expected_response) do
          {
            total_records: 1,
            records: [
              {
                id: 12,
                ip_address: ip2
              }
            ],
            related_hostnames: [
              {
                hostname: hostname2,
                count: 1
              }
            ],
            error: nil
          }
        end

        before :each do
          get(:index, params: { page: page, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with both included and excluded optional params' do
        let(:included) { hostname2 }
        let(:excluded) { hostname1 }

        let(:expected_response) do
          {
            total_records: 1,
            records: [
              {
                id: 16,
                ip_address: ip2
              }
            ],
            related_hostnames: [
              {
                hostname: hostname2,
                count: 1
              }
            ],
            error: nil
          }
        end

        before :each do
          get(:index, params: { page: page, included: included, excluded: excluded })
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns only the non-excluded dns records with a related hostname' do
          expect(parsed_body).to eq expected_response
        end
      end
    end

    context 'without the required page param' do
      before :each do
        get(:index)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#create' do
    context 'with the required and valid inputs' do
     
      let(:ip1) { '1.1.1.1' }
      let(:ip2) { '1.1.1.1' }
      let(:hostname1) { 'lorem.com' }
      let(:hostname2) { 'renato.com' }

      context 'with one hostname' do

        let(:payload) do
          {
            dns_records: {
              ip: ip1,
              hostnames_attributes: [
                {
                  hostname: hostname1
                }
              ]
            }
          }.to_json
        end

        let(:expected_response) do
          {
            id: 18,
            error: nil
          }
        end

        before do
          request.accept = 'application/json'
          request.content_type = 'application/json'

          post(:create, body: payload, format: :json)
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the id inserted' do
          expect(parsed_body).to eq expected_response
        end
      end

      context 'with two hostnames' do

        let(:payload) do
          {
            dns_records: {
              ip: ip2,
              hostnames_attributes: [
                {
                  hostname: hostname1
                },
                {
                  hostname: hostname2
                }
              ]
            }
          }.to_json
        end


        let(:expected_response) do
          {
            id: 20,
            error: nil
          }
        end

        before do
          request.accept = 'application/json'
          request.content_type = 'application/json'

          post(:create, body: payload, format: :json)
        end

        it 'responds with valid response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the id inserted' do
          expect(parsed_body).to eq expected_response
        end
      end
    end

    context 'without ip address' do

      let(:ip1) { nil }
      let(:hostname) { 'lorem.com' }

      let(:payload) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: hostname
              }
            ]
          }
        }.to_json
      end


      let(:expected_response) do
        {
          id: nil,
          error: 'IP not valid!'
        }
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload, format: :json)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        expect(parsed_body).to eq expected_response
      end
    end

    context 'without any hostname' do

      let(:ip1) { '1.1.1.1' }

      let(:payload) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              
            ]
          }
        }.to_json
      end


      let(:expected_response) do
        {
          id: nil,
          error: 'Missing hostname param'
        }
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload, format: :json)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        expect(parsed_body).to eq expected_response
      end
    end

    context 'with an invalid ip address' do

      let(:ip1) { '111111.1.1.1' }
      let(:hostname) { 'lorem.com' }

      let(:payload) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: hostname
              }
            ]
          }
        }.to_json
      end


      let(:expected_response) do
        {
          id: nil,
          error: 'IP not valid!'
        }
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload, format: :json)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        expect(parsed_body).to eq expected_response
      end
    end

    context 'with an invalid hostaname' do

      let(:ip1) { '1.1.1.1' }
      let(:hostname) { 'lorem@324324.com' }

      let(:payload) do
        {
          dns_records: {
            ip: ip1,
            hostnames_attributes: [
              {
                hostname: hostname
              }
            ]
          }
        }.to_json
      end


      let(:expected_response) do
        {
          id: nil,
          error: 'Some of the hostnames are not valid'
        }
      end

      before do
        request.accept = 'application/json'
        request.content_type = 'application/json'

        post(:create, body: payload, format: :json)
      end

      it 'responds with unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        expect(parsed_body).to eq expected_response
      end
    end
  end
end
