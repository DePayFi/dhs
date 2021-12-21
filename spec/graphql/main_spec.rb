# frozen_string_literal: true

require 'rails_helper'

describe 'main graphql support' do
  let(:network) { 'ethereum' }
  let(:address) { '0x317D875cA3B9f8d14f960486C0d1D1913be74e90' }

  let!(:stubbed_request) do
    stub_request(:post, 'https://graphql.bitquery.io/')
    .with(
      body: {
        query: %{
          query ($network: EthereumNetwork!, $address: String!) {
            ethereum(network: $network) {
              address(address: {is: $address}) {
                balances {
                  currency {
                    address
                    name
                    symbol
                    decimals
                    tokenType
                  }
                  value
                }
              }
            }
          }
        }.squish,
        variables: {
          "network": network,
          "address": address
        }.to_json
      }.to_json
    ).to_return(body: {
      "data": {
        "ethereum": {
          "address": [
            {
              balances: [
                {
                  "currency": {
                    "address": '-',
                    "name": 'Ether',
                    "decimals": 18,
                    "symbol": 'ETH',
                    "tokenType": ''
                  },
                  "value": 0.11741978
                },
                {
                  "currency": {
                    "address": '0xb63b606ac810a52cca15e44bb630fd42d8d1d83d',
                    "name": 'Monaco',
                    "decimals": 8,
                    "symbol": 'MCO',
                    "tokenType": 'ERC20'
                  },
                  "value": 0
                },
                {
                  "currency": {
                    "address": '0x06012c8cf97bead5deae237070f9587f8e7a266d',
                    "name": 'CryptoKitties',
                    "decimals": 0,
                    "symbol": 'CK',
                    "tokenType": 'ERC721'
                  },
                  "value": 90
                },
                {
                  "currency": {
                    "address": '0xdac17f958d2ee523a2206206994597c13d831ec7',
                    "name": 'Tether USD',
                    "decimals": 6,
                    "symbol": 'USDT',
                    "tokenType": 'ERC20'
                  },
                  "value": 10
                }
              ]
            }
          ]
        }
      }
    }.to_json)
  end

  before do
    class Record < DHS::Record

      configuration items_key: [:data, :ethereum, :address, 0, :balances]

      endpoint 'https://graphql.bitquery.io/',
        graphql: {
          query: %{
            query ($network: EthereumNetwork!, $address: String!) {
              ethereum(network: $network) {
                address(address: {is: $address}) {
                  balances {
                    currency {
                      address
                      name
                      symbol
                      decimals
                      tokenType
                    }
                    value
                  }
                }
              }
            }
          },
          variables: %i[network address]
        }
    end
  end

  it 'fetches data from graphql and converts it into DHS Record structure' do
    records = Record.where(network: 'ethereum', address: '0x317D875cA3B9f8d14f960486C0d1D1913be74e90').fetch
    expect(records.first.currency.name).to eq 'Ether'
  end
end
