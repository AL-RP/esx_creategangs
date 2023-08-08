<template>
  <v-container fluid fill-height>
    <v-row justify="center" align="center">
      <v-card elevation="2" width="500px" maxWidth="500px" class="px-5 py-5">
        <v-card-title>
          <span class="mr-3">Gang Creator</span>
          <span
            ><v-icon color="primary" size="2rem"
              >mdi-account-group</v-icon
            ></span
          >
        </v-card-title>
        <v-card-subtitle>Create your gang and define the roles</v-card-subtitle>
        <v-alert type="error" dark shaped v-if="error">{{ error }}</v-alert>

        <!-- Gang Name -->
        <v-text-field
          outlined
          label="Gang Name"
          v-model="gangName"
        ></v-text-field>

        <!-- Roles -->
        <v-data-table :headers="headers" :items="roles" class="elevation-1"
          >//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
          <template v-slot:item="{ item, index }">
            <tr>
              <td>
                <v-icon
                  small
                  color="red"
                  v-if="item.role !== 'Boss (you)'"
                  @click="removeRole(item)"
                  >mdi-minus</v-icon
                >
                <v-icon
                  small
                  color="green"
                  v-if="index === roles.length - 1"
                  @click="addRole"
                  >mdi-plus</v-icon
                >
              </td>
              <td>
                <v-text-field
                  v-model="item.role"
                  :rules="roleRules"
                  v-if="item.role !== 'Boss (you)'"
                  label="Role"
                  single-line
                  counter="20"
                  dense
                ></v-text-field>
                <span v-else>{{ item.role }}</span>
              </td>
              <td>
                <v-text-field
                  v-model="item.salary"
                  :rules="salaryRules"
                  label="Salary"
                  single-line
                  counter
                  dense
                ></v-text-field>
              </td>
            </tr>
          </template>
        </v-data-table>

        <!-- Dialogs -->
        <v-dialog v-model="dialog" max-width="500px">
          <v-card>
            <v-card-title class="headline error mb-3"
              >Confirmation</v-card-title
            >
            <v-card-text>
              Are you sure you want to create this gang? <br />
              This will cost you XXXXX $.
            </v-card-text>
            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="error" text @click="dialog = false">Cancel</v-btn>
              <v-btn color="green" text @click="confirmGangCreation"
                >Confirm</v-btn
              >
            </v-card-actions>
          </v-card>
        </v-dialog>

        <v-spacer></v-spacer>

        <!-- Actions -->
        <v-card-actions>
          <v-btn class="ml-auto" color="error" @click="exitMenu">CANCEL</v-btn>
          <v-btn color="green" @click="createGang">Create Gang</v-btn>
        </v-card-actions>
      </v-card>
    </v-row>
  </v-container>
</template>

<script>
import { mapGetters } from "vuex";
import api from "../api/axios";

export default {
  name: "GangCreator",
  data() {
    return {
      dialog: false,
      error: "",
      gangName: "",
      headers: [
        { text: "Actions", sortable: false },
        { text: "Role", value: "role" },
        { text: "Salary", value: "salary", sortable: false },
      ],
      roles: [{ role: "Boss (you)", salary: "1000" }],
    };
  },
  computed: {
    ...mapGetters(["playerID"]),
  },
  methods: {
    sendError(text) {
      this.error = text;
      setTimeout(() => {
        this.error = "";
      }, 3000);
    },
    addRole() {
      this.roles.push({ role: "", salary: "" });
    },
    removeRole(role) {
      this.roles = this.roles.filter((r) => r !== role);
    },
    async createGang() {
      this.dialog = true;
    },
    async exitMenu() {
      window.postMessage({ type: "esx_creategang:hideGangCreator" }, "*");
    },
    async confirmGangCreation() {
      try {
        // Trigger the 'esx_creategang:registerGang' server event and send the gang name
        await api.post("triggerEvent", {
          event: "esx_creategang:registerGang",
          data: {
            gangName: this.gangName,
            gangLabel: this.gangName,
          },
        });

        // After the gang has been created, loop through the roles array and add each role to the gang
        for (const role of this.roles) {
          // Don't add the 'Boss' role since it has already been added when the gang was created
          if (role.role !== "Boss (you)") {
            await api.post("triggerEvent", {
              event: "esx_creategang:addGangGrade",
              data: {
                gangName: this.gangName,
                gradeName: role.role,
                gradeLabel: role.role,
                salary: role.salary,
              },
            });
          }
        }
      } catch (error) {
        this.sendError(error.message);
      } finally {
        // Whether the gang creation is successful or not, close the dialog
        this.dialog = false;
      }
    },
  },
};
</script>

<style scoped>
.v-card {
  background-color: #2b2b2b;
  opacity: 1;
  color: #ffffff;
}

.v-card__actions {
  margin-top: 10px;
}
</style>
