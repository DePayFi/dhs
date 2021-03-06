# frozen_string_literal: true

require 'rails_helper'

describe DHS::Complex do
  it 'returns nil when result is empty' do
    expect(DHS::Complex.reduce([])).to be_nil
  end

  it 'forwards primitive types' do
    expect(DHS::Complex.reduce(entry_id: 123)).to eq(entry_id: 123)
  end

  it 'fails when trying to merge primitive types' do
    expect {
      DHS::Complex.reduce([{ entry: true }, { entry: :content }])
    }.to raise_error(ArgumentError)
  end

  it 'does not fail trying to merge primitive types when they are the same' do
    expect {
      DHS::Complex.reduce([{ entry: true }, { entry: true }])
    }.not_to raise_error
  end

  context 'first level' do
    context 'reduces symbols into/with X' do
      it 'reduces symbols into hash' do
        expect(DHS::Complex.reduce([
          { entries: :contract },
          :entries
        ])).to eq(entries: :contract)
      end

      it 'reduces symbols into array' do
        expect(DHS::Complex.reduce([
          [:contracts],
          :entries
        ])).to eq(%i[contracts entries])
        expect(DHS::Complex.reduce([
          [:entries],
          :entries
        ])).to eq(:entries)
      end

      it 'reduces symbols with symbols' do
        expect(DHS::Complex.reduce(%i[
          contracts
          entries
        ])).to eq(%i[contracts entries])
        expect(DHS::Complex.reduce(%i[
          entries
          entries
        ])).to eq(:entries)
      end
    end

    context 'reduces arrays into/with X' do
      it 'reduces arrays into an hash' do
        expect(DHS::Complex.reduce([
          { entries: :contract },
          [:entries]
        ])).to eq(entries: :contract)
        expect(DHS::Complex.reduce([
          { entries: :contract },
          [:products]
        ])).to eq([{ entries: :contract }, :products])
      end

      it 'reduces arrays into an arrays' do
        expect(DHS::Complex.reduce([
          [:entries],
          [:entries]
        ])).to eq(:entries)
        expect(DHS::Complex.reduce([
          [:entries],
          [:products]
        ])).to eq(%i[entries products])
      end

      it 'reduces arrays into an symbols' do
        expect(DHS::Complex.reduce([
          :entries,
          [:entries]
        ])).to eq(:entries)
        expect(DHS::Complex.reduce([
          :entries,
          [:products]
        ])).to eq(%i[entries products])
      end
    end

    context 'reduces hashes into/with X' do
      it 'reduces hash into an hash' do
        expect(DHS::Complex.reduce([
          { entries: :contract },
          { entries: :products }
        ])).to eq(entries: %i[contract products])
        expect(DHS::Complex.reduce([
          { entries: :contract },
          { entries: :contract }
        ])).to eq(entries: :contract)
      end

      it 'reduces hash into an array' do
        expect(DHS::Complex.reduce([
          [:entries],
          { entries: :products }
        ])).to eq(entries: :products)
        expect(DHS::Complex.reduce([
          [{ entries: :contract }],
          { entries: :contract }
        ])).to eq(entries: :contract)
      end

      it 'reduces hash into a symbol' do
        expect(DHS::Complex.reduce([
          :entries,
          { entries: :products }
        ])).to eq(entries: :products)
        expect(DHS::Complex.reduce([
          :products,
          { entries: :contract }
        ])).to eq([:products, { entries: :contract }])
      end
    end

    context 'reduces array into/with X' do
      it 'reduces array into hash' do
        expect(DHS::Complex.reduce([
          { entries: :contract },
          %i[entries products]
        ])).to eq([{ entries: :contract }, :products])
      end

      it 'reduces array into array' do
        expect(DHS::Complex.reduce([
          [:contracts],
          %i[entries products contracts]
        ])).to eq(%i[contracts entries products])
      end

      it 'reduces array with symbols' do
        expect(DHS::Complex.reduce([
          :contracts,
          %i[entries products]
        ])).to eq(%i[contracts entries products])
      end
    end
  end

  context 'multi-level' do
    it 'reduces a complex multi-level example' do
      expect(DHS::Complex.reduce([
        :contracts,
        [:entries, products: { content_ads: :address }],
        products: { content_ads: { place: :location } }
      ])).to eq([
        :contracts,
        :entries,
        products: { content_ads: [:address, { place: :location }] }
      ])
    end

    it 'reduces another complex multi-level example' do
      expect(DHS::Complex.reduce([
        [entries: :content_ads, products: :price],
        [:entries, products: { content_ads: :address }],
        [entries: { content_ads: :owner }, products: [{ price: :region }, :image, { content_ads: :owner }]]
      ])).to eq(
        entries: { content_ads: :owner },
        products: [{ content_ads: %i[address owner], price: :region }, :image]
      )
    end

    it 'reduces another complex multi-level example (single plus array)' do
      expect(DHS::Complex.reduce([
        { entries: :products },
        { entries: %i[customer contracts] }
      ])).to eq(
        entries: %i[products customer contracts]
      )
    end

    it 'reduces another complex multi-level example (single hash plus array)' do
      expect(DHS::Complex.reduce([
        { entries: { customer: :contracts } },
        { entries: %i[customer content_ads] }
      ])).to eq(
        entries: [{ customer: :contracts }, :content_ads]
      )
    end

    it 'reduces properly' do
      expect(DHS::Complex.reduce([
        %i[entries place content_ads], [{ place: :content_ads }], { content_ads: :place }
      ])).to eq(
        [:entries, { place: :content_ads, content_ads: :place }]
      )
    end
  end
end
