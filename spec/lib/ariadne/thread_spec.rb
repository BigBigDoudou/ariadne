# frozen_string_literal: true

require "ariadne/thread"

RSpec.describe Ariadne::Thread do
  subject(:thread) do
    described_class.new(
      include_paths: ["spec/dummy/app"]
    )
  end

  let(:call) do
    thread.call { Services::Example.new.call }
  end

  describe "#call" do
    it "output traces" do
      expect { call }.to output.to_stdout
    end
  end

  describe "#seams" do
    let(:seams_data) do
      seam_methods = %i[rank depth klass method_name prefix]
      parameter_methods = %i[param arg]
      thread.seams.map do |seam|
        seam_methods.to_h { [_1, seam.public_send(_1)] }.tap do |hash|
          hash[:parameters] =
            seam.parameters.map do |parameter|
              parameter_methods.to_h { [_1, parameter.public_send(_1)] }
            end
        end
      end
    end

    let(:expectations) do
      [
        {
          rank: 0,
          depth: 0,
          klass: Services::Example,
          method_name: :call,
          prefix: "#",
          parameters: []
        },
        {
          rank: 1,
          depth: 1,
          klass: Services::Example,
          method_name: :method_with_args_and_kwargs,
          prefix: "#",
          parameters: [
            { arg: 1, param: :a },
            { arg: 2, param: :b },
            { arg: "foo", param: :x },
            { arg: "bar", param: :y }
          ]
        },
        {
          rank: 2,
          depth: 2,
          klass: Services::Example,
          method_name: :method_with_anonymous_args_and_kwargs,
          prefix: "#",
          parameters: [
            { arg: [1, 2], param: :args },
            { arg: { x: "foo", y: "bar" }, param: :kwargs },
            { arg: kind_of(Proc), param: :block }
          ]
        },
        {
          rank: 3,
          depth: 3,
          klass: Services::Example,
          method_name: :method_forwarding_all_args,
          prefix: "#",
          parameters: [
            { arg: ["<?>"], param: "..." }
          ]
        },
        {
          rank: 4,
          depth: 4,
          klass: Services::Example,
          method_name: :class_method,
          prefix: ".",
          parameters: [
            { arg: Integer, param: :klass }
          ]
        }
      ]
    end

    before do
      # do not output during the tests to avoid vizual pollution
      log = double(Ariadne::Log, call: nil)
      allow(Ariadne::Log).to receive(:new).and_return(log)
      call
    end

    it "returns the seams" do
      expect(seams_data.size).to eq 5
      expectations.each.with_index do |expectation, index|
        expect(seams_data.find { _1[:rank] == index }).to match(expectation)
      end
    end
  end
end
