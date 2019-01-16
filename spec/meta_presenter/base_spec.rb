require 'spec_helper'

describe MetaPresenter::Base do

  describe '#inspect' do
    subject { presenter.inspect }

    let(:controller_class) { ApplicationController }
    let(:controller) { controller_class.new }
    let(:action_name) { 'test' }
    let(:presenter) { controller.view_context.presenter }
    
    before do
      allow(controller).to receive(:action_name).and_return(action_name)
    end

    it { is_expected.to eql('#<ApplicationPresenter>') }
  end
end