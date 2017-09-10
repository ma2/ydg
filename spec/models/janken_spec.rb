require 'rails_helper'

RSpec.describe Janken, :type => :model do
  fixtures :all
  after do
    Timecop.return
  end
  describe '.result' do
    context 'jid=201708101200' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 12, 16))
      end
      it 'ぐーが1つ、ちょきが1つ、勝利はぐーの集計が返ること' do
        expect(Janken.result('201708101200')).to eq ( { 1 => 1, 0 => 1, 'v' => 0} )
      end
    end
  end
  describe '.aggregate' do
    context 'jid=201708101200' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 12, 16))
      end
      it 'u01一勝、u02一敗になること' do
        Janken.aggregate
        expect(users(:u01).q3).to eq 1
        expect(users(:u01).q4).to eq 0
        expect(users(:u02).q3).to eq 0
        expect(users(:u02).q4).to eq 1
      end
    end
    context 'jid=201708101230' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 12, 46))
      end
      it 'u01一勝、u02、u03一敗になること' do
        Janken.aggregate
        expect(users(:u01).q3).to eq 1
        expect(users(:u01).q4).to eq 0
        expect(users(:u02).q3).to eq 0
        expect(users(:u02).q4).to eq 1
        expect(users(:u03).q3).to eq 0
        expect(users(:u03).q4).to eq 1
      end
    end
    context 'jid=201708101330' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 13, 46))
      end
      it 'u02一勝、u01、u03一敗になること' do
        Janken.aggregate
        expect(users(:u01).q3).to eq 0
        expect(users(:u01).q4).to eq 1
        expect(users(:u02).q3).to eq 1
        expect(users(:u02).q4).to eq 0
        expect(users(:u03).q3).to eq 0
        expect(users(:u03).q4).to eq 1
      end
    end
    context 'jid=201708101500' do
      before do
        Timecop.freeze(Time.local(2017, 8, 10, 15, 20))
      end
      it 'u01一勝、u03一敗になること' do
        Janken.aggregate
        expect(users(:u01).q3).to eq 1
        expect(users(:u01).q4).to eq 0
        expect(users(:u03).q3).to eq 0
        expect(users(:u03).q4).to eq 1
      end
    end
    context 'jid=201708152200' do
      before do
        Timecop.freeze(Time.local(2017, 8, 15, 22, 20))
      end
      it 'u01、u02ひきわけになること' do
        Janken.aggregate
        expect(users(:u01).q3).to eq 0
        expect(users(:u01).q4).to eq 0
        expect(users(:u01).q5).to eq 1
        expect(users(:u02).q3).to eq 0
        expect(users(:u02).q4).to eq 0
        expect(users(:u02).q5).to eq 1
      end
    end
  end
  describe '#victory' do
    context 'jid=201708101200' do
      it 'ぐーの勝ちで0が返ること' do
        janken = jankens(:jk01)
        expect(janken.victory).to eq 0
      end
    end
    context 'jid=201708101230' do
      it 'あいこ（ちょきの勝ち）で1が返ること' do
        janken = jankens(:jk02)
        expect(janken.victory).to eq 1
      end
    end
    context 'jid=201708101330' do
      it 'ちょきの勝ちで1が返ること' do
        janken = jankens(:jk03)
        expect(janken.victory).to eq 1
      end
    end
    context 'jid=201708101330' do
      it 'ぱーの勝ちで2が返ること' do
        janken = jankens(:jk04)
        expect(janken.victory).to eq 2
      end
    end
    context 'jid=201708152200' do
      it 'あいこで-1が返ること' do
        janken = jankens(:jk05)
        expect(janken.victory).to eq -1
      end
    end
  end
end

