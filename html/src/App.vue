<template>
  <v-app dark v-if="isVisible">
    <component :is="view" />
  </v-app>
</template>

<script>
import GangCreator from "./views/GangCreator";
import { mapMutations } from "vuex";

export default {
  name: "App",
  data: () => ({
    view: GangCreator,
    isVisible: false,
  }),
  methods: {
    ...mapMutations(["setPlayerID"]),
    // Switch between views and toggle visibility.
    toggleShow(view) {
      switch (view) {
        case "GangCreator":
          this.view = GangCreator;
          break;
        default:
          break;
      }
      this.isVisible = !this.isVisible;
    },
  },
  // Listen to messages from the window.
  mounted() {
    this.listener = window.addEventListener("message", (e) => {
      const item = e.data || e.detail;
      if (!item || !item.type) {
        console.error("Received unknown message type or missing type:", JSON.stringify(item));
        return;
      }
      if (this[item.type]) this[item.type](item);
    });
  },
  // Clean up the listener once the component is destroyed.
  destroyed() {
    window.removeEventListener("message", this.listener);
  },
};
</script>
  
<style>
::-webkit-scrollbar {
  width: 0;
  display: inline !important;
}
.v-application {
  background: rgb(0, 0, 0, 0.5) !important;
}
</style>
