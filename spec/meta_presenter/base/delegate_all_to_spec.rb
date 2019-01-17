require 'spec_helper'

describe MetaPresenter::Base::DelegateAllTo do

  describe '.delegate_all_to' do
    subject { presenter.send(method_name) }

    let(:controller_class) { PagesController }
    let(:controller) { controller_class.new }
    let(:action_name) { 'logs' }
    let(:presenter) { controller.view_context.presenter }

    let(:controller_all_instance_methods) { controller.class.instance_methods(true) }
    let(:presenter_all_instance_methods) { presenter.class.instance_methods(true) }

    let(:delegate_object) { controller.send(delegate_object_method_name) }
    let(:delegate_object_method_name) { :character }

    before do
      # stub action name on the controller
      allow(controller).to receive(:action_name).and_return(action_name)

      controller.class.define_method(delegate_object_method_name) do
        OpenStruct.new(name: "Mario")
      end

      # set up the controller to delegate all to an object
      presenter.class.delegate_all_to = delegate_object_method_name
    end

    def define_method_on_presenter
      presenter.class.define_method(method_name) do
        "presenter retval"
      end
    end

    def define_method_on_controller
      controller.class.define_method(method_name) do
        "controller retval"
      end
    end

    context "delegating a method the object responds to" do
      let(:method_name) { :name }

      before do
        expect(delegate_object).to respond_to(method_name)
      end

      context "and presenter doesn't define the method" do
        before do
          expect(presenter_all_instance_methods).to_not include(method_name)
        end

        context "and controller doesn't define the method" do
          before do
            expect(controller_all_instance_methods).to_not include(method_name)
          end

          it "calls the method on the delegated object" do
            expect(subject).to eql(delegate_object.send(method_name))
          end
        end

        context "but controller defines the method" do
          before do
            define_method_on_controller
            expect(controller_all_instance_methods).to include(method_name)
          end

          it "still calls the method on the delegated object" do
            expect(subject).to eql(delegate_object.send(method_name))
          end
        end
      end

      context "but presenter also defines the method" do
        before do
          define_method_on_presenter
          expect(presenter_all_instance_methods).to include(method_name)
        end

        it "calls the presenter defined method" do
          expect(subject).to eql("presenter retval")
        end
      end
    end

    context "delegating a method the object doesn't respond to" do
      let(:method_name) { :age }

      before do
        expect(delegate_object).to_not respond_to(method_name)
      end

      context "and presenter doesn't define the method" do
        before do
          expect(presenter_all_instance_methods).to_not include(method_name)
        end

        it { expect { subject }.to raise_error(NoMethodError, "undefined method `#{method_name}' for #<Pages::LogsPresenter>") }
      end

      context "but presenter defines the method" do
        before do
          define_method_on_presenter
          expect(presenter_all_instance_methods).to include(method_name)
        end

        it "calls the presenter defined method" do
          expect(subject).to eql("presenter retval")
        end
      end
    end
  end
end