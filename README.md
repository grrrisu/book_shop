# BookShop

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## EventStorming Diagram

The diagram follows Event Storming conventions with color coding:

- **🟠 Orange**: Domain Events (the key business events that happen)
- **📘 Blue**: Commands (actions that trigger events)
- **🟡 Yellow**: Aggregates/Bounded Contexts (your GenServer modules)
- **📗 Green**: Read Models/Views (data projections)
- **🟣 Purple**: Policies/Business Rules (reactive behaviors)
- **👤 Pink**: Actors/Personas (users and external systems)

The diagram shows the complete reactive flow:

1. **Customer Journey**: Customer buys books → order placed → books shipped → payment → newsletter → repeat
2. **Inventory Management**: Auto-reordering when stock is low
3. **Event-Driven Architecture**: All components react to events via PubSub
4. **Business Policies**: Tax calculation, inventory checks, periodic newsletters

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
