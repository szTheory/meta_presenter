require 'spec_helper'

describe MetaPresenter::Base::DelegateToController do

  describe 'delegating a method to controller' do
    subject { presenter.send(method_name) }

    let(:controller_class) { PagesController }
    let(:controller) { controller_class.new }
    let(:action_name) { 'logs' }
    let(:presenter) { controller.view_context.presenter }

    before do
      allow(controller).to receive(:action_name).and_return(action_name)
    end

    let(:directly_defined_instance_methods) { controller.class.instance_methods(false) }
    let(:inherited_instance_methods) { controller.class.instance_methods(true) }

    context "method exists on the controller" do
      before do
        expect(controller).to respond_to(method_name)
      end

      context "on the same class" do
        let(:method_name) { :a_method_defined_on_pages_controller }

        before do
          expect(directly_defined_instance_methods).to include(method_name)
        end

        it { is_expected.to eql("pages controller method return value") }
        it { expect(presenter).to respond_to(method_name) }
      end

      context "on a superclass" do
        let(:method_name) { :a_method_defined_on_application_controller }

        before do
          expect(directly_defined_instance_methods).to_not include(method_name)
          expect(inherited_instance_methods).to include(method_name)
        end

        it { is_expected.to eql("application controller method return value") }
        it { expect(presenter).to respond_to(method_name) }
      end
    end

    context "method doesn't exist on the controller" do
      let(:method_name) { :a_method_not_defined_on_controller }

      before do
        expect(directly_defined_instance_methods).to_not include(method_name)
        expect(inherited_instance_methods).to_not include(method_name)
      end

      it { expect { subject }.to raise_error(NoMethodError) }
      it { expect(presenter).to_not respond_to(method_name) }
    end
  end
end