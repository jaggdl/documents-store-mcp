// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
import {
  MarksmithController,
  ListContinuationController,
} from "@avo-hq/marksmith";

eagerLoadControllersFrom("controllers", application);

application.register("marksmith", MarksmithController);
application.register("list-continuation", ListContinuationController);
